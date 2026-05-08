from __future__ import annotations

import numpy as np
import pandas as pd
import statsmodels.api as sm
from pathlib import Path
from config import PROCESSED_DIR, TABLE_DIR
from prepare_data import main as prepare_main


def load_processed() -> pd.DataFrame:
    path = PROCESSED_DIR / "chicken_demand_processed.parquet"
    if not path.exists():
        prepare_main()
    return pd.read_parquet(path)


def run_ols(df: pd.DataFrame) -> pd.DataFrame:
    dat = df[["qc", "pf", "y", "pb"]].replace([np.inf, -np.inf], np.nan).dropna()
    X = sm.add_constant(dat[["pf", "y", "pb"]])
    y = dat["qc"]
    fit = sm.OLS(y, X).fit(cov_type="HC1")

    rows = []
    for term in fit.params.index:
        b = fit.params[term]
        se = fit.bse[term]
        rows.append({
            "model": "OLS_HC1",
            "term": term,
            "estimate": b,
            "std_error": se,
            "conf_low": b - 1.96 * se,
            "conf_high": b + 1.96 * se,
            "p_value": fit.pvalues[term],
            "n": int(fit.nobs),
        })
    return pd.DataFrame(rows)


def main() -> pd.DataFrame:
    df = load_processed()
    out = run_ols(df)
    path = TABLE_DIR / "python_ols_results.csv"
    out.to_csv(path, index=False)
    print(f"MQO salvo em: {path}")
    return out


if __name__ == "__main__":
    main()
