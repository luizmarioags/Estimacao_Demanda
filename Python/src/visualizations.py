from __future__ import annotations

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm

from config import PROCESSED_DIR, TABLE_DIR, FIG_DIR
from prepare_data import main as prepare_main
from ols import main as ols_main
from first_stage import main as fs_main
from iv_2sls import main as iv_main


def load_processed() -> pd.DataFrame:
    path = PROCESSED_DIR / "chicken_demand_processed.parquet"
    if not path.exists():
        prepare_main()
    return pd.read_parquet(path)


def ensure_tables() -> None:
    if not (TABLE_DIR / "python_ols_results.csv").exists():
        ols_main()
    if not (TABLE_DIR / "python_first_stage_results.csv").exists():
        fs_main()
    if not (TABLE_DIR / "python_iv_results.csv").exists():
        iv_main()


def savefig(name: str) -> None:
    path = FIG_DIR / name
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()
    print(f"Figura salva: {path}")


def plot_series(df: pd.DataFrame) -> None:
    xvar = "year" if "year" in df.columns else "time"
    vars_ = ["qc", "pf", "y", "pb", "pc"]

    fig, axes = plt.subplots(len(vars_), 1, figsize=(8, 10), sharex=True)
    for ax, v in zip(axes, vars_):
        ax.plot(df[xvar], df[v], linewidth=1.5)
        ax.set_ylabel(v)
        ax.grid(True, alpha=0.25)
    axes[-1].set_xlabel("Ano")
    fig.suptitle("Séries temporais das variáveis principais", y=1.01)
    savefig("01_series_temporais_variaveis_principais_python.png")


def plot_scatter_qc_pf(df: pd.DataFrame) -> None:
    x = df["pf"]
    y = df["qc"]
    fit = np.polyfit(x, y, deg=1)
    x_grid = np.linspace(x.min(), x.max(), 100)
    y_grid = fit[0] * x_grid + fit[1]

    plt.figure(figsize=(8, 5))
    plt.scatter(x, y, alpha=0.8)
    plt.plot(x_grid, y_grid, linewidth=1.5)
    plt.xlabel("pf = log(preço real do galeto)")
    plt.ylabel("qc = log(quantidade consumida per capita)")
    plt.title("Correlação bruta entre quantidade e preço do galeto")
    plt.grid(True, alpha=0.25)
    savefig("02_scatter_qc_pf_mqo_python.png")


def plot_coefficients() -> None:
    ols = pd.read_csv(TABLE_DIR / "python_ols_results.csv")
    iv = pd.read_csv(TABLE_DIR / "python_iv_results.csv")

    ols_pf = ols.loc[ols["term"] == "pf", ["estimate", "conf_low", "conf_high"]].copy()
    ols_pf["model"] = "MQO"
    ols_pf = ols_pf.rename(columns={"estimate": "beta_p"})[["model", "beta_p", "conf_low", "conf_high"]]

    coef = pd.concat([ols_pf, iv[["model", "beta_p", "conf_low", "conf_high"]]], ignore_index=True)
    order = ["MQO"] + [f"Z{i}" for i in range(1, 11)]
    coef["model"] = pd.Categorical(coef["model"], categories=order, ordered=True)
    coef = coef.sort_values("model")
    y_pos = np.arange(len(coef))

    plt.figure(figsize=(8, 6))
    xerr = np.vstack([coef["beta_p"] - coef["conf_low"], coef["conf_high"] - coef["beta_p"]])
    plt.errorbar(coef["beta_p"], y_pos, xerr=xerr, fmt="o", capsize=3)
    plt.axvline(0, linestyle="--", linewidth=1)
    plt.yticks(y_pos, coef["model"].astype(str))
    plt.xlabel("beta_p")
    plt.ylabel("Modelo")
    plt.title("Elasticidade-preço estimada: MQO versus 2SLS")
    plt.grid(True, axis="x", alpha=0.25)
    savefig("03_coeficientes_beta_p_mqo_2sls_python.png")


def plot_f_statistics() -> None:
    stata_path = TABLE_DIR / "stata_iv_results_weakivtest.csv"
    if stata_path.exists():
        ftab = pd.read_csv(stata_path)
        value_col = "F_eff"
        ylabel = "F efetiva de Montiel Olea-Pflueger"
        title = "Força dos instrumentos por especificação: weakivtest"
    else:
        ftab = pd.read_csv(TABLE_DIR / "python_iv_results.csv")
        value_col = "first_stage_F_robust_not_MOP"
        ylabel = "F robusta auxiliar do primeiro estágio"
        title = "Força dos instrumentos por especificação: F robusta auxiliar"

    order = [f"Z{i}" for i in range(1, 11)]
    ftab["model"] = pd.Categorical(ftab["model"], categories=order, ordered=True)
    ftab = ftab.sort_values("model")

    plt.figure(figsize=(8, 5))
    plt.bar(ftab["model"].astype(str), ftab[value_col])
    plt.axhline(10, linestyle="--", linewidth=1)
    plt.axhline(23.1, linestyle=":", linewidth=1)
    plt.xlabel("Conjunto de instrumentos")
    plt.ylabel(ylabel)
    plt.title(title)
    plt.grid(True, axis="y", alpha=0.25)
    savefig("04_f_instrumentos_por_modelo_python.png")


def plot_first_stage(df: pd.DataFrame) -> None:
    instruments = ["pc", "pc_l1", "exp_pc", "exp_pc_l1"]
    fig, axes = plt.subplots(2, 2, figsize=(10, 6))
    axes = axes.ravel()

    for ax, inst in zip(axes, instruments):
        dat = df[["pf", inst]].replace([np.inf, -np.inf], np.nan).dropna()
        ax.scatter(dat[inst], dat["pf"], alpha=0.8)
        fit = np.polyfit(dat[inst], dat["pf"], deg=1)
        x_grid = np.linspace(dat[inst].min(), dat[inst].max(), 100)
        ax.plot(x_grid, fit[0] * x_grid + fit[1], linewidth=1.5)
        ax.set_title(f"pf contra {inst}")
        ax.set_xlabel(inst)
        ax.set_ylabel("pf")
        ax.grid(True, alpha=0.25)

    fig.suptitle("Primeiro estágio: preço do galeto e instrumentos selecionados", y=1.02)
    savefig("05_primeiro_estagio_scatter_instrumentos_python.png")


def plot_residuals(df: pd.DataFrame) -> None:
    dat = df[["qc", "pf", "y", "pb"]].dropna()
    X = sm.add_constant(dat[["pf", "y", "pb"]])
    model = sm.OLS(dat["qc"], X).fit()
    fitted = model.fittedvalues
    resid = model.resid

    lowess = sm.nonparametric.lowess(resid, fitted, frac=0.6)

    plt.figure(figsize=(8, 5))
    plt.scatter(fitted, resid, alpha=0.8)
    plt.plot(lowess[:, 0], lowess[:, 1], linewidth=1.5)
    plt.axhline(0, linestyle="--", linewidth=1)
    plt.xlabel("Valores ajustados")
    plt.ylabel("Resíduos")
    plt.title("Resíduos versus valores ajustados no MQO")
    plt.grid(True, alpha=0.25)
    savefig("06_residuos_versus_ajustados_mqo_python.png")


def main() -> None:
    df = load_processed()
    ensure_tables()
    plot_series(df)
    plot_scatter_qc_pf(df)
    plot_coefficients()
    plot_f_statistics()
    plot_first_stage(df)
    plot_residuals(df)
    print("Gráficos Python salvos em output/figures/.")


if __name__ == "__main__":
    main()
