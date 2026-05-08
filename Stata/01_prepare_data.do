/********************************************************************
 01_prepare_data.do
 Prepara a base da demanda por galeto
********************************************************************/

do "Stata/config.do"

* ------------------------------------------------------------
* 1. Lê a base
* ------------------------------------------------------------

cap confirm file "$RAWCSV"
if _rc {
    cap confirm file "$RAWDTA"
    if _rc {
        di as text "Base não encontrada em data/raw/. Tentando baixar automaticamente..."
        do "Stata/00_download_data.do"
    }
}

cap confirm file "$RAWCSV"
if !_rc {
    import delimited using "$RAWCSV", clear varnames(1) case(lower)
}
else {
    cap confirm file "$RAWDTA"
    if !_rc {
        use "$RAWDTA", clear
        rename *, lower
    }
    else {
        cap confirm file "$RAWPARQUET"
        if !_rc {
            di as error "Stata não lê Parquet nativamente sem ferramentas adicionais. Converta para CSV/DTA ou use R/Python para preparar a base."
            exit 601
        }
        else {
            di as error "Base não encontrada. Coloque chicken_demand.csv ou chicken_demand.dta em data/raw/."
            exit 601
        }
    }
}

* ------------------------------------------------------------
* 2. Verifica variáveis mínimas
* ------------------------------------------------------------

foreach v in q y pchick pbeef pcor cpi time {
    cap confirm variable `v'
    if _rc {
        di as error "Variável ausente: `v'"
        exit 111
    }
}

* ------------------------------------------------------------
* 3. Evita conflitos de nomes
* ------------------------------------------------------------

* FIX: renomeia 'pf' do dataset bruto (preço do insumo/feed) para
*      liberar o nome para o log do preço do frango.
cap rename pf pf_feed

rename q q_raw
rename y income_real

* Se PC e PB já existirem, serão usados como preços reais.
cap confirm variable pc
if !_rc {
    gen double price_chick_real = pc
}
else {
    gen double price_chick_real = pchick / cpi
}

cap confirm variable pb
if !_rc {
    gen double price_beef_real = pb
}
else {
    gen double price_beef_real = pbeef / cpi
}

gen double price_corn_real = pcor / cpi

* Remove variáveis anteriores caso existam por acaso.
cap drop qc pf y pb pc pc2 pc3 pc_l1 pc2_l1 exp_pc exp_pc2 exp_pc3 exp_pc_l1 exp_pc2_l1

* ------------------------------------------------------------
* 4. Gera variáveis da lista
* ------------------------------------------------------------

gen double qc = ln(q_raw)
gen double pf = ln(price_chick_real)
gen double y  = ln(income_real)
gen double pb = ln(price_beef_real)
gen double pc = ln(price_corn_real)

sort time
tsset time

gen double pc2    = pc^2
gen double pc3    = pc^3
gen double pc_l1  = L.pc
gen double pc2_l1 = pc_l1^2

gen double exp_pc     = exp(pc)
gen double exp_pc2    = exp(pc^2)
gen double exp_pc3    = exp(pc^3)
gen double exp_pc_l1  = exp(pc_l1)
gen double exp_pc2_l1 = exp(pc_l1^2)

* Mantém observações válidas nos modelos básicos.
drop if missing(qc, pf, y, pb, pc)

save "$PROCDIR/chicken_demand_processed.dta", replace
export delimited using "$PROCDIR/chicken_demand_processed.csv", replace

di as result "Base processada salva em $PROCDIR."
