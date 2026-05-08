# ============================================================
# 03_first_stage.R
# Item 4: primeiros estágios para Z1...Z10
# ============================================================

source("R/00_setup.R")

processed_path <- file.path(PROCESSED_DIR, "chicken_demand_processed.rds")
if (!file.exists(processed_path)) source("R/01_prepare_data.R")

df <- readRDS(processed_path)

instrument_sets <- list(
  Z1  = c("pc"),
  Z2  = c("pc", "pc2"),
  Z3  = c("pc", "pc2", "pc3"),
  Z4  = c("pc_l1"),
  Z5  = c("pc_l1", "pc2_l1"),
  Z6  = c("exp_pc"),
  Z7  = c("exp_pc", "exp_pc2"),
  Z8  = c("exp_pc", "exp_pc2", "exp_pc3"),
  Z9  = c("exp_pc_l1"),
  Z10 = c("exp_pc_l1", "exp_pc2_l1")
)

run_first_stage <- function(model_name, zvars, df) {
  needed <- c("pf", "y", "pb", zvars)
  dat    <- df |> filter(if_all(all_of(needed), ~ is.finite(.x)))

  fml <- as.formula(paste("pf ~ y + pb +", paste(zvars, collapse = " + ")))
  fit <- lm(fml, data = dat)
  vc  <- sandwich::vcovHC(fit, type = "HC1")

  lh       <- car::linearHypothesis(fit, zvars, vcov. = vc, test = "F")
  f_robust <- as.numeric(lh$F[2])
  p_robust <- as.numeric(lh$`Pr(>F)`[2])

  broom::tidy(lmtest::coeftest(fit, vcov. = vc)) |>
    rename(std_error = std.error, p_value = p.value) |>
    mutate(model = model_name, n = nobs(fit), f_robust = f_robust, f_p_value = p_robust)
}

first_stage_table <- bind_rows(
  lapply(names(instrument_sets), function(nm) {
    run_first_stage(nm, instrument_sets[[nm]], df)
  })
)

readr::write_csv(first_stage_table, file.path(TABLE_DIR_R, "r_first_stage_results.csv"))
message("Primeiros estágios concluídos. Resultado salvo em ", file.path(TABLE_DIR_R, "r_first_stage_results.csv"))
