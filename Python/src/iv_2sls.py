from __future__ import annotations

import numpy as np
import pandas as pd
from linearmodels.iv import IV2SLS
from config import PROCESSED_DIR, TABLE_DIR, INSTRUMENT_SETS
from prepare_data import main as prepare_main
from first_stage import run_first_stage


def load_processed() -> pd.DataFrame:
    path = PROCESSED_DIR / "chicken_demand_processed.parquet"
    if not path.exists():
        prepare_main()
    return pd.read_parquet(path)


def run_iv_models(df: pd.DataFrame) -> pd.DataFrame:
    first_stage = run_first_stage(df).set_index("model")
    rows = []

    for model, zvars in INSTRUMENT_SETS.items():
        cols = ["qc", "pf", "y", "pb"] + zvars
        dat = df[cols].replace([np.inf, -np.inf], np.nan).dropna()

        dep = dat["qc"]
        exog = dat[["y", "pb"]]
        endog = dat["pf"]
        instr = dat[zvars]

        fit = IV2SLS(dep, exog, endog, instr).fit(cov_type="robust")

        b = fit.params["pf"]
        se = fit.std_errors["pf"]
        rows.append({
            "model": model,
            "instruments": " ".join(zvars),
            "beta_p": b,
            "std_error": se,
            "conf_low": b - 1.96 * se,
            "conf_high": b + 1.96 * se,
            "n": int(fit.nobs),
            "first_stage_F_robust_not_MOP": first_stage.loc[model, "F_robust_first_stage_not_MOP"],
            "note": "Para o teste oficial de instrumentos fracos, rode Stata/04_iv_2sls_weakivtest.do",
        })

    return pd.DataFrame(rows)


def main() -> pd.DataFrame:
    df = load_processed()
    out = run_iv_models(df)
    path = TABLE_DIR / "python_iv_results.csv"
    out.to_csv(path, index=False)
    print(f"2SLS em Python salvo em: {path}")
    return out


if __name__ == "__main__":
    main()
