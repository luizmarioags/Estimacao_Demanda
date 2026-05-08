/********************************************************************
 00_master.do
 Executa toda a replicação no Stata
********************************************************************/

clear all
set more off
version 17

capture log close _all
log using "output/logs/stata_master.log", replace text

do "Stata/config.do"

* Pacotes necessários
cap which ivreg2
if _rc ssc install ivreg2, replace

cap which ranktest
if _rc ssc install ranktest, replace

cap which weakivtest
if _rc ssc install weakivtest, replace

* Executa scripts
do "Stata/00_download_data.do"
do "Stata/01_prepare_data.do"
do "Stata/02_ols.do"
do "Stata/03_first_stage.do"
do "Stata/04_iv_2sls_weakivtest.do"
do "Stata/05_visualizations.do"

log close

di as result "Replicação Stata concluída. Veja output/tables/ e output/figures/."
