# ============================================================
# 01_prepare_data.R
# Prepara a base da demanda por galeto
# ============================================================

source("R/00_setup.R")
source("R/00_download_data.R")

find_raw_file <- function() {
  candidates <- c(
    file.path(RAW_DIR, "chicken_demand.csv"),
    file.path(RAW_DIR, "chicken_demand.dta"),
    file.path(RAW_DIR, "chicken_demand.parquet")
  )
  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    message("Base não encontrada em data/raw/. Tentando baixar automaticamente...")
    download_broiler_data(force = FALSE)
    existing <- candidates[file.exists(candidates)]
  }
  if (length(existing) == 0) {
    stop(
      "Base não encontrada. Coloque a base em data/raw/ com um destes nomes: ",
      "chicken_demand.csv, chicken_demand.dta ou chicken_demand.parquet.",
      call. = FALSE
    )
  }
  existing[1]
}

read_any <- function(path) {
  ext <- tools::file_ext(path) |> tolower()
  if (ext == "csv") {
    readr::read_csv(path, show_col_types = FALSE)
  } else if (ext == "dta") {
    if (!requireNamespace("haven", quietly = TRUE)) {
      install.packages("haven", repos = "https://cloud.r-project.org")
    }
    haven::read_dta(path)
  } else if (ext == "parquet") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      install.packages("arrow", repos = "https://cloud.r-project.org")
    }
    arrow::read_parquet(path)
  } else {
    stop("Formato não suportado: ", ext, call. = FALSE)
  }
}

prepare_chicken_demand <- function(raw) {
  df <- raw |> janitor::clean_names()

  required <- c("q", "y", "pchick", "pbeef", "pcor", "cpi", "time")
  missing <- setdiff(required, names(df))
  if (length(missing) > 0) {
    stop("Variáveis ausentes na base: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  df <- df |>
    rename(
      q_raw      = q,
      income_real = y
    )

  if ("pc" %in% names(df)) {
    df <- df |> mutate(price_chick_real = .data$pc)
  } else {
    df <- df |> mutate(price_chick_real = .data$pchick / .data$cpi)
  }

  if ("pb" %in% names(df)) {
    df <- df |> mutate(price_beef_real = .data$pb)
  } else {
    df <- df |> mutate(price_beef_real = .data$pbeef / .data$cpi)
  }

  df <- df |>
    mutate(
      price_corn_real = .data$pcor / .data$cpi,
      qc = log(.data$q_raw),
      pf = log(.data$price_chick_real),
      y  = log(.data$income_real),
      pb = log(.data$price_beef_real),
      pc = log(.data$price_corn_real)
    ) |>
    arrange(.data$time) |>
    mutate(
      pc2       = .data$pc^2,
      pc3       = .data$pc^3,
      pc_l1     = dplyr::lag(.data$pc, 1),
      pc2_l1    = .data$pc_l1^2,
      exp_pc    = exp(.data$pc),
      exp_pc2   = exp(.data$pc^2),
      exp_pc3   = exp(.data$pc^3),
      exp_pc_l1  = exp(.data$pc_l1),
      exp_pc2_l1 = exp(.data$pc_l1^2)
    )

  df <- df |>
    filter(if_all(c(qc, pf, y, pb, pc), ~ is.finite(.x)))

  df
}

raw_file <- find_raw_file()
message("Lendo base: ", raw_file)
raw_data <- read_any(raw_file)
df       <- prepare_chicken_demand(raw_data)

readr::write_csv(df, file.path(PROCESSED_DIR, "chicken_demand_processed.csv"))
saveRDS(df,          file.path(PROCESSED_DIR, "chicken_demand_processed.rds"))

message("Base processada salva em data/processed/.")
