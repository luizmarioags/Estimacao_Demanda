/********************************************************************
 02_ols.do
 Item 1: MQO com erros robustos
********************************************************************/

do "Stata/config.do"

use "$PROCDIR/chicken_demand_processed.dta", clear

reg qc pf y pb, vce(robust)

* Guarda resultados antes de mexer na base.
scalar N_ols = e(N)

tempfile olsresults
postfile H str20 model str20 term double estimate std_error conf_low conf_high p_value N using `olsresults', replace

foreach v in pf y pb _cons {
    scalar b = _b[`v']
    scalar se = _se[`v']
    scalar cil = b - invnormal(0.975)*se
    scalar cih = b + invnormal(0.975)*se
    scalar pval = 2*ttail(e(df_r), abs(b/se))
    post H ("OLS_HC1") ("`v'") (b) (se) (cil) (cih) (pval) (N_ols)
}

postclose H
use `olsresults', clear
export delimited using "$TABLEDIR/stata_ols_results.csv", replace
save "$TABLEDIR/stata_ols_results.dta", replace

di as result "MQO concluído. Resultado salvo em output/tables/stata_ols_results.csv"
