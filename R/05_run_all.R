# ============================================================
# 05_run_all.R
# Executa toda a replicação em R
# ============================================================

source("R/00_download_data.R")
download_broiler_data(force = FALSE)

source("R/01_prepare_data.R")
source("R/02_ols.R")
source("R/03_first_stage.R")
source("R/04_iv_2sls.R")
source("R/06_visualizations.R")

message("Replicação em R concluída.")
message("Atenção: para a estatística F efetiva de Montiel Olea-Pflueger, rode o pacote Stata com weakivtest.")
