/********************************************************************
 config.do
 Configura caminhos do pacote
********************************************************************/

clear all
set more off
version 17

* Diretório raiz: assume que o do-file foi chamado a partir da raiz.
global ROOT "`c(pwd)'"
global RAWDIR "$ROOT/data/raw"
global PROCDIR "$ROOT/data/processed"
global OUTDIR "$ROOT/output"
global TABLEDIR "$ROOT/output/tables"
global LOGDIR "$ROOT/output/logs"
global FIGDIR "$ROOT/output/figures"

cap mkdir "$PROCDIR"
cap mkdir "$OUTDIR"
cap mkdir "$TABLEDIR"
cap mkdir "$LOGDIR"
cap mkdir "$FIGDIR"

* Arquivo de entrada. O master tenta CSV, DTA e depois PARQUET.
global RAWCSV "$RAWDIR/chicken_demand.csv"
global RAWDTA "$RAWDIR/chicken_demand.dta"
global RAWPARQUET "$RAWDIR/chicken_demand.parquet"

di as text "ROOT: $ROOT"
