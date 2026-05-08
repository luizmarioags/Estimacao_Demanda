# ============================================================
# 06_visualizations.R
# Gráficos para ilustrar os resultados da Lista 1
# ============================================================

source("R/00_setup.R")

processed_path <- file.path(PROCESSED_DIR, "chicken_demand_processed.rds")
if (!file.exists(processed_path)) source("R/01_prepare_data.R")

# Garante que as tabelas principais existam.
if (!file.exists(file.path(TABLE_DIR, "r_ols_results.csv"))) source("R/02_ols.R")
if (!file.exists(file.path(TABLE_DIR, "r_first_stage_results.csv"))) source("R/03_first_stage.R")
if (!file.exists(file.path(TABLE_DIR, "r_iv_results.csv"))) source("R/04_iv_2sls.R")

df <- readRDS(processed_path)

year_var <- if ("year" %in% names(df)) "year" else "time"
fig <- function(name) file.path(FIG_DIR, name)

base_theme <- theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title.position = "plot",
    panel.grid.minor = element_blank()
  )

# ------------------------------------------------------------
# 1. Séries temporais das variáveis em log
# ------------------------------------------------------------
series_df <- df |>
  select(all_of(year_var), qc, pf, y, pb, pc) |>
  pivot_longer(-all_of(year_var), names_to = "variavel", values_to = "valor")

p_series <- ggplot(series_df, aes(x = .data[[year_var]], y = valor)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~ variavel, scales = "free_y", ncol = 1) +
  labs(
    x = "Ano",
    y = "Log da variável",
    title = "Séries temporais das variáveis principais"
  ) +
  base_theme

ggsave(fig("01_series_temporais_variaveis_principais.png"), p_series, width = 8, height = 10, dpi = 300)

# ------------------------------------------------------------
# 2. Dispersão qc versus pf com reta MQO
# ------------------------------------------------------------
p_scatter <- ggplot(df, aes(x = pf, y = qc)) +
  geom_point(size = 2, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  labs(
    x = "pf = log(preço real do galeto)",
    y = "qc = log(quantidade consumida per capita)",
    title = "Correlação bruta entre quantidade e preço do galeto"
  ) +
  base_theme

ggsave(fig("02_scatter_qc_pf_mqo.png"), p_scatter, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------
# 3. Coeficientes beta_p: MQO e 2SLS Z1...Z10
# ------------------------------------------------------------
ols_tbl <- readr::read_csv(file.path(TABLE_DIR, "r_ols_results.csv"), show_col_types = FALSE) |>
  filter(term == "pf") |>
  transmute(model = "MQO", beta_p = estimate, conf_low, conf_high)

iv_tbl <- readr::read_csv(file.path(TABLE_DIR, "r_iv_results.csv"), show_col_types = FALSE) |>
  transmute(model, beta_p, conf_low, conf_high)

coef_tbl <- bind_rows(ols_tbl, iv_tbl) |>
  mutate(model = factor(model, levels = c("MQO", paste0("Z", 1:10))))

p_coef <- ggplot(coef_tbl, aes(x = model, y = beta_p)) +
  geom_hline(yintercept = 0, linewidth = 0.4) +
  geom_pointrange(aes(ymin = conf_low, ymax = conf_high), linewidth = 0.6) +
  coord_flip() +
  labs(
    x = "Modelo",
    y = expression(beta[p]),
    title = "Elasticidade-preço estimada: MQO versus 2SLS"
  ) +
  base_theme

ggsave(fig("03_coeficientes_beta_p_mqo_2sls.png"), p_coef, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------
# 4. F efetiva do weakivtest por especificação, se houver Stata;
#    caso contrário, usa F robusta auxiliar do primeiro estágio em R.
# ------------------------------------------------------------
stata_iv_path <- file.path(TABLE_DIR, "stata_iv_results_weakivtest.csv")
if (file.exists(stata_iv_path)) {
  f_tbl <- readr::read_csv(stata_iv_path, show_col_types = FALSE) |>
    transmute(model, F_value = F_eff, tipo = "F efetiva - weakivtest/Stata")
  ylab <- "F efetiva de Montiel Olea-Pflueger"
  f_title <- "Força dos instrumentos por especificação: weakivtest"
} else {
  f_tbl <- readr::read_csv(file.path(TABLE_DIR, "r_iv_results.csv"), show_col_types = FALSE) |>
    transmute(model, F_value = first_stage_F_robust_not_MOP, tipo = "F robusta auxiliar - R")
  ylab <- "F robusta auxiliar do primeiro estágio"
  f_title <- "Força dos instrumentos por especificação: F robusta auxiliar"
}

f_tbl <- f_tbl |>
  mutate(model = factor(model, levels = paste0("Z", 1:10)))

p_f <- ggplot(f_tbl, aes(x = model, y = F_value)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 10, linetype = "dashed") +
  geom_hline(yintercept = 23.1, linetype = "dotted") +
  labs(
    x = "Conjunto de instrumentos",
    y = ylab,
    title = f_title,
    subtitle = "Linhas de referência meramente informativas: 10 e 23,1"
  ) +
  base_theme

ggsave(fig("04_f_instrumentos_por_modelo.png"), p_f, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------
# 5. Primeiro estágio: relação de pf com instrumentos selecionados
# ------------------------------------------------------------
fs_long <- df |>
  select(pf, pc, pc_l1, exp_pc, exp_pc_l1) |>
  pivot_longer(-pf, names_to = "instrumento", values_to = "valor") |>
  filter(is.finite(valor), is.finite(pf))

p_fs <- ggplot(fs_long, aes(x = valor, y = pf)) +
  geom_point(size = 1.8, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  facet_wrap(~ instrumento, scales = "free_x") +
  labs(
    x = "Instrumento ou transformação",
    y = "pf = log(preço real do galeto)",
    title = "Primeiro estágio: preço do galeto e instrumentos selecionados"
  ) +
  base_theme

ggsave(fig("05_primeiro_estagio_scatter_instrumentos.png"), p_fs, width = 10, height = 6, dpi = 300)

# ------------------------------------------------------------
# 6. Resíduos versus ajustados no MQO
# ------------------------------------------------------------
ols_model_path <- file.path(PROCESSED_DIR, "r_ols_model.rds")
if (!file.exists(ols_model_path)) source("R/02_ols.R")
ols <- readRDS(ols_model_path)
resid_df <- tibble::tibble(
  fitted = fitted(ols),
  residual = resid(ols)
)

p_resid <- ggplot(resid_df, aes(x = fitted, y = residual)) +
  geom_hline(yintercept = 0, linewidth = 0.4) +
  geom_point(size = 2, alpha = 0.8) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 0.8) +
  labs(
    x = "Valores ajustados",
    y = "Resíduos",
    title = "Resíduos versus valores ajustados no MQO"
  ) +
  base_theme

ggsave(fig("06_residuos_versus_ajustados_mqo.png"), p_resid, width = 8, height = 5, dpi = 300)

message("Gráficos salvos em output/figures/.")
