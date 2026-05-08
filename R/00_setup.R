# ============================================================
# 00_setup.R
# Instala e carrega pacotes necessários
# ============================================================

required_packages <- c(
  "readr", "dplyr", "tidyr", "janitor", "stringr", "AER", "sandwich",
  "lmtest", "broom", "car", "modelsummary", "ggplot2", "scales"
)

install_if_missing <- function(pkgs) {
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing) > 0) {
    install.packages(missing, repos = "https://cloud.r-project.org")
  }
}

install_if_missing(required_packages)

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(janitor)
  library(stringr)
  library(AER)
  library(sandwich)
  library(lmtest)
  library(broom)
  library(car)
  library(modelsummary)
  library(ggplot2)
  library(scales)
})

ROOT <- normalizePath(".", winslash = "/", mustWork = FALSE)
RAW_DIR <- file.path(ROOT, "data", "raw")
PROCESSED_DIR <- file.path(ROOT, "data", "processed")
TABLE_DIR <- file.path(ROOT, "output", "tables")
FIG_DIR <- file.path(ROOT, "output", "figures")
LOG_DIR <- file.path(ROOT, "output", "logs")

for (d in c(RAW_DIR, PROCESSED_DIR, TABLE_DIR, FIG_DIR, LOG_DIR)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

message("Diretório raiz: ", ROOT)
