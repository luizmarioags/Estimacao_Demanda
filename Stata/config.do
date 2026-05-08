/********************************************************************
 config.do
 Configura caminhos do pacote
********************************************************************/

clear all
set more off
version 17

* Diretório raiz: assume que o do-file foi chamado a partir da raiz.
global ROOT    "`c(pwd)'"
global RAWDIR  "$ROOT/data/raw"
global PROCDIR "$ROOT/data/processed"
global OUTDIR  "$ROOT/output"

* Subdiretórios de output (nível base).
global TABLEDIR "$OUTDIR/tables"
global LOGDIR   "$OUTDIR/logs"
global FIGDIR   "$OUTDIR/figures"

* Subdiretórios Stata dentro de cada pasta de output.
global TABLEDIR_STATA "$TABLEDIR/Stata"
global LOGDIR_STATA   "$LOGDIR/Stata"
global FIGDIR_STATA   "$FIGDIR/Stata"

* Cria todos os diretórios necessários.
cap mkdir "$PROCDIR"
cap mkdir "$OUTDIR"
cap mkdir "$TABLEDIR"
cap mkdir "$LOGDIR"
cap mkdir "$FIGDIR"
cap mkdir "$TABLEDIR_STATA"
cap mkdir "$LOGDIR_STATA"
cap mkdir "$FIGDIR_STATA"

* Arquivos de entrada.
global RAWCSV     "$RAWDIR/chicken_demand.csv"
global RAWDTA     "$RAWDIR/chicken_demand.dta"
global RAWPARQUET "$RAWDIR/chicken_demand.parquet"

di as text "ROOT: $ROOT"
