/********************************************************************
 04_iv_2sls_weakivtest.do
 Itens 2 e 5: 2SLS + weakivtest

 O teste de instrumentos fracos pedido na lista é executado por:
     weakivtest
 após cada ivreg2.
********************************************************************/

do "Stata/config.do"

use "$PROCDIR/chicken_demand_processed.dta", clear

cap which ivreg2
if _rc ssc install ivreg2, replace

cap which weakivtest
if _rc ssc install weakivtest, replace

* Conjuntos de instrumentos excluídos.
global Z1  "pc"
global Z2  "pc pc2"
global Z3  "pc pc2 pc3"
global Z4  "pc_l1"
global Z5  "pc_l1 pc2_l1"
global Z6  "exp_pc"
global Z7  "exp_pc exp_pc2"
global Z8  "exp_pc exp_pc2 exp_pc3"
global Z9  "exp_pc_l1"
global Z10 "exp_pc_l1 exp_pc2_l1"

tempfile ivresults
postfile H str5 model str80 instruments double beta_p std_error conf_low conf_high F_eff c_TSLS_5 c_TSLS_10 N using `ivresults', replace

forvalues i = 1/10 {
    local zlist "${Z`i'}"
    di as text "Estimando modelo Z`i': `zlist'"

    quietly ivreg2 qc y pb (pf = `zlist'), robust first

    scalar b = _b[pf]
    scalar se = _se[pf]
    scalar ci_l = b - invnormal(0.975)*se
    scalar ci_h = b + invnormal(0.975)*se
    scalar nobs = e(N)

    * weakivtest é a rotina principal de instrumentos fracos.
    quietly weakivtest

    capture scalar feff = r(F_eff)
    if _rc scalar feff = .

    capture scalar c5 = r(c_TSLS_5)
    if _rc scalar c5 = .

    capture scalar c10 = r(c_TSLS_10)
    if _rc scalar c10 = .

    post H ("Z`i'") ("`zlist'") (b) (se) (ci_l) (ci_h) (feff) (c5) (c10) (nobs)
}

postclose H
use `ivresults', clear

gen str40 ci_95 = "[" + string(conf_low, "%9.4f") + "; " + string(conf_high, "%9.4f") + "]"
gen byte rejects_weak_5pct_TSLS = F_eff > c_TSLS_5 if !missing(F_eff, c_TSLS_5)
gen byte rejects_weak_10pct_TSLS = F_eff > c_TSLS_10 if !missing(F_eff, c_TSLS_10)

order model instruments beta_p ci_95 F_eff c_TSLS_5 c_TSLS_10 rejects_weak_5pct_TSLS rejects_weak_10pct_TSLS std_error conf_low conf_high N

export delimited using "$TABLEDIR/stata_iv_results_weakivtest.csv", replace
export excel using "$TABLEDIR/stata_iv_results_weakivtest.xlsx", firstrow(variables) replace
save "$TABLEDIR/stata_iv_results_weakivtest.dta", replace

di as result "2SLS + weakivtest concluídos. Resultado salvo em output/tables/stata_iv_results_weakivtest.csv"
