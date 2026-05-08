/********************************************************************
 05_visualizations.do
 Gráficos para ilustrar os resultados da Lista 1
********************************************************************/

do "Stata/config.do"

cap mkdir "$FIGDIR"

* ------------------------------------------------------------
* 1. Séries temporais padronizadas das variáveis principais
* ------------------------------------------------------------
use "$PROCDIR/chicken_demand_processed.dta", clear

cap confirm variable year
if !_rc local xvar year
else local xvar time

foreach v in qc pf y pb pc {
    quietly summarize `v'
    gen double z_`v' = (`v' - r(mean))/r(sd)
}

twoway ///
    (line z_qc `xvar', lpattern(solid)) ///
    (line z_pf `xvar', lpattern(dash)) ///
    (line z_y  `xvar', lpattern(shortdash)) ///
    (line z_pb `xvar', lpattern(dot)) ///
    (line z_pc `xvar', lpattern(longdash)), ///
    legend(order(1 "qc" 2 "pf" 3 "y" 4 "pb" 5 "pc") rows(1)) ///
    ytitle("Variável padronizada") xtitle("Ano") ///
    title("Séries temporais das variáveis principais")
graph export "$FIGDIR/01_series_temporais_variaveis_principais_stata.png", replace width(2400)

* ------------------------------------------------------------
* 2. Dispersão qc versus pf com reta MQO
* ------------------------------------------------------------
twoway (scatter qc pf) (lfit qc pf), ///
    xtitle("pf = log(preço real do galeto)") ///
    ytitle("qc = log(quantidade consumida per capita)") ///
    title("Correlação bruta entre quantidade e preço do galeto") ///
    legend(off)
graph export "$FIGDIR/02_scatter_qc_pf_mqo_stata.png", replace width(2400)

* ------------------------------------------------------------
* 3. Coeficientes beta_p: MQO e 2SLS
* ------------------------------------------------------------
tempfile iv ols coef
import delimited using "$TABLEDIR/stata_iv_results_weakivtest.csv", clear
keep model beta_p conf_low conf_high
save `iv', replace

import delimited using "$TABLEDIR/stata_ols_results.csv", clear
keep if term == "pf"
replace model = "MQO"
rename estimate beta_p
keep model beta_p conf_low conf_high
append using `iv'

gen order_model = .
replace order_model = 1 if model == "MQO"
forvalues i = 1/10 {
    replace order_model = `i' + 1 if model == "Z`i'"
}
sort order_model

twoway (rcap conf_low conf_high order_model, horizontal) ///
       (scatter order_model beta_p), ///
       ylab(1 "MQO" 2 "Z1" 3 "Z2" 4 "Z3" 5 "Z4" 6 "Z5" 7 "Z6" 8 "Z7" 9 "Z8" 10 "Z9" 11 "Z10", angle(0)) ///
       xline(0, lpattern(dash)) ///
       xtitle("beta_p") ytitle("Modelo") ///
       title("Elasticidade-preço estimada: MQO versus 2SLS") ///
       legend(off)
graph export "$FIGDIR/03_coeficientes_beta_p_mqo_2sls_stata.png", replace width(2400)

* ------------------------------------------------------------
* 4. F efetiva do weakivtest por especificação
* ------------------------------------------------------------
import delimited using "$TABLEDIR/stata_iv_results_weakivtest.csv", clear
gen model_num = _n

twoway (bar f_eff model_num, barwidth(.65)) ///
       (scatter f_eff model_num), ///
       yline(10, lpattern(dash)) ///
       yline(23.1, lpattern(dot)) ///
       xlab(1 "Z1" 2 "Z2" 3 "Z3" 4 "Z4" 5 "Z5" 6 "Z6" 7 "Z7" 8 "Z8" 9 "Z9" 10 "Z10") ///
       xtitle("Conjunto de instrumentos") ///
       ytitle("F efetiva de Montiel Olea-Pflueger") ///
       title("Força dos instrumentos por especificação") ///
       legend(off)
graph export "$FIGDIR/04_f_instrumentos_por_modelo_stata.png", replace width(2400)

* ------------------------------------------------------------
* 5. Primeiro estágio: pf contra instrumentos selecionados
* ------------------------------------------------------------
use "$PROCDIR/chicken_demand_processed.dta", clear

twoway (scatter pf pc) (lfit pf pc), title("pf contra pc") legend(off) name(g1, replace)
twoway (scatter pf pc_l1) (lfit pf pc_l1), title("pf contra pc defasado") legend(off) name(g2, replace)
twoway (scatter pf exp_pc) (lfit pf exp_pc), title("pf contra exp(pc)") legend(off) name(g3, replace)
twoway (scatter pf exp_pc_l1) (lfit pf exp_pc_l1), title("pf contra exp(pc defasado)") legend(off) name(g4, replace)
graph combine g1 g2 g3 g4, title("Primeiro estágio: preço do galeto e instrumentos selecionados")
graph export "$FIGDIR/05_primeiro_estagio_scatter_instrumentos_stata.png", replace width(2400)

* ------------------------------------------------------------
* 6. Resíduos versus ajustados no MQO
* ------------------------------------------------------------
reg qc pf y pb, vce(robust)
predict double fitted_ols, xb
predict double resid_ols, resid

twoway (scatter resid_ols fitted_ols) (lowess resid_ols fitted_ols), ///
    yline(0, lpattern(dash)) ///
    xtitle("Valores ajustados") ytitle("Resíduos") ///
    title("Resíduos versus valores ajustados no MQO") ///
    legend(off)
graph export "$FIGDIR/06_residuos_versus_ajustados_mqo_stata.png", replace width(2400)

di as result "Gráficos Stata salvos em output/figures/."
