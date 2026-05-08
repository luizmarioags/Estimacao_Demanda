# ============================================================
# 04_iv_2sls.R
# Itens 2 e 5: 2SLS para Z1...Z10
# Observação: o teste principal de instrumentos fracos é o weakivtest no Stata.
# Aqui calculamos 2SLS e F robusta do primeiro estágio apenas como apoio.
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

first_stage_f <- function(dat, zvars) {
  fml <- as.formula(paste("pf ~ y + pb +", paste(zvars, collapse = " + ")))
  fit <- lm(fml, data = dat)
  vc  <- sandwich::vcovHC(fit, type = "HC1")
  lh  <- car::linearHypothesis(fit, zvars, vcov. = vc, test = "F")
  as.numeric(lh$F[2])
}

run_iv <- function(model_name, zvars, df) {
  needed <- c("qc", "pf", "y", "pb", zvars)
  dat    <- df |> filter(if_all(all_of(needed), ~ is.finite(.x)))

  fml <- as.formula(
    paste("qc ~ pf + y + pb | y + pb +", paste(zvars, collapse = " + "))
  )

  fit <- AER::ivreg(fml, data = dat)
  vc  <- sandwich::vcovHC(fit, type = "HC1")

  b    <- coef(fit)["pf"]
  se   <- sqrt(diag(vc))["pf"]
  f_fs <- first_stage_f(dat, zvars)

  tibble::tibble(
    model                        = model_name,
    beta_p                       = as.numeric(b),
    std_error                    = as.numeric(se),
    conf_low                     = as.numeric(b - 1.96 * se),
    conf_high                    = as.numeric(b + 1.96 * se),
    n                            = nobs(fit),
    first_stage_F_robust_not_MOP = f_fs,
    note                         = "Para o teste oficial de instrumentos fracos da lista, use Stata/04_iv_2sls_weakivtest.do"
  )
}

iv_table <- bind_rows(
  lapply(names(instrument_sets), function(nm) run_iv(nm, instrument_sets[[nm]], df))
)

readr::write_csv(iv_table, file.path(TABLE_DIR_R, "r_iv_results.csv"))
message("2SLS em R concluído. Resultado salvo em ", file.path(TABLE_DIR_R, "r_iv_results.csv"))
