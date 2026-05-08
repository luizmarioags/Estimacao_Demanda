/********************************************************************
 03_first_stage.do
 Item 4: primeiros estágios para Z1...Z10
********************************************************************/

do "Stata/config.do"

use "$PROCDIR/chicken_demand_processed.dta", clear

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

tempfile firststage
postfile H str5 model str80 instruments double F_robust p_value N using `firststage', replace

forvalues i = 1/10 {
    local zlist "${Z`i'}"
    quietly regress pf y pb `zlist', vce(robust)
    quietly test `zlist'
    local F = r(F)
    local p = r(p)
    local N = e(N)
    post H ("Z`i'") ("`zlist'") (`F') (`p') (`N')
}

postclose H
use `firststage', clear

export delimited using "$TABLEDIR_STATA/stata_first_stage_results.csv", replace
save "$TABLEDIR_STATA/stata_first_stage_results.dta", replace

di as result "Primeiros estágios concluídos. Resultado salvo em $TABLEDIR_STATA/stata_first_stage_results.csv"
