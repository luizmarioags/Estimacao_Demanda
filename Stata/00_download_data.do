/********************************************************************
 00_download_data.do
 Baixa a base broiler/chicken demand usada na lista.
 O arquivo é salvo como data/raw/chicken_demand.csv.
********************************************************************/

do "Stata/config.do"

cap set httptimeout 120

local broiler_url "https://mitocw.ups.edu.ec/courses/economics/14-271-industrial-organization-i-fall-2005/assignments/broiler.csv"

cap confirm file "$RAWCSV"
if !_rc {
    di as result "Base já existe em $RAWCSV."
    exit
}

cap mkdir "$RAWDIR"

di as text "Baixando base de: `broiler_url'"
copy "`broiler_url'" "$RAWCSV", replace

* Verificação mínima.
import delimited using "$RAWCSV", clear varnames(1) case(lower)
foreach v in year q y pchick pbeef pcor pf cpi qproda pop meatex time {
    cap confirm variable `v'
    if _rc {
        di as error "Download feito, mas variável esperada ausente: `v'"
        exit 111
    }
}

file open src using "$RAWDIR/SOURCE_broiler.txt", write replace
file write src "Base: broiler/chicken demand" _n
file write src "Fonte baixada: `broiler_url'" _n
file write src "Arquivo operacional do pacote: data/raw/chicken_demand.csv" _n
file close src

di as result "Base salva em $RAWCSV."
