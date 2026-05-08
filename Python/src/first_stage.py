from __future__ import annotations

import numpy as np
import pandas as pd
import statsmodels.api as sm
from config import PROCESSED_DIR, TABLE_DIR, INSTRUMENT_SETS
from prepare_data import main as prepare_main


def load_processed() -> pd.DataFrame:
    path = PROCESSED_DIR / "chicken_demand_processed.parquet"
    if not path.exists():
        prepare_main()
    return pd.read_parquet(path)


def robust_f_test(fit, zvars):
    names = list(fit.params.index)
    R = np.zeros((len(zvars), len(names)))
    for i, z in enumerate(zvars):
        R[i, names.index(z)] = 1.0
    ft = fit.f_test(R)
    return float(ft.fvalue), float(ft.pvalue)


def run_first_stage(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for model, zvars in INSTRUMENT_SETS.items():
        cols = ["pf", "y", "pb"] + zvars
        dat = df[cols].replace([np.inf, -np.inf], np.nan).dropna()
        X = sm.add_constant(dat[["y", "pb"] + zvars])
        fit = sm.OLS(dat["pf"], X).fit(cov_type="HC1")
        fval, pval = robust_f_test(fit, zvars)
        rows.append({
            "model": model,
            "instruments": " ".join(zvars),
            "F_robust_first_stage_not_MOP": fval,
            "p_value": pval,
            "n": int(fit.nobs),
        })
    return pd.DataFrame(rows)


def main() -> pd.DataFrame:
    df = load_processed()
    out = run_first_stage(df)
    path = TABLE_DIR / "python_first_stage_results.csv"
    out.to_csv(path, index=False)
    print(f"Primeiro estágio salvo em: {path}")
    return out


if __name__ == "__main__":
    main()
