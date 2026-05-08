# ============================================================
# 02_ols.R
# Item 1: demanda por MQO com erros robustos
# ============================================================

source("R/00_setup.R")

processed_path <- file.path(PROCESSED_DIR, "chicken_demand_processed.rds")
if (!file.exists(processed_path)) source("R/01_prepare_data.R")

df <- readRDS(processed_path)

ols <- lm(qc ~ pf + y + pb, data = df)
vc  <- sandwich::vcovHC(ols, type = "HC1")

ols_table <- broom::tidy(lmtest::coeftest(ols, vcov. = vc)) |>
  rename(
    std_error = std.error,
    p_value   = p.value
  ) |>
  mutate(
    conf_low  = estimate - 1.96 * std_error,
    conf_high = estimate + 1.96 * std_error,
    model     = "OLS_HC1"
  ) |>
  select(model, term, estimate, std_error, conf_low, conf_high, statistic, p_value)

readr::write_csv(ols_table, file.path(TABLE_DIR_R, "r_ols_results.csv"))
saveRDS(ols, file.path(PROCESSED_DIR, "r_ols_model.rds"))

message("MQO concluído. Resultado salvo em ", file.path(TABLE_DIR_R, "r_ols_results.csv"))
