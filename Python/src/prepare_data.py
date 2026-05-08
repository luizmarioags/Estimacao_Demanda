from __future__ import annotations

import numpy as np
import pandas as pd
from pathlib import Path
from config import RAW_CANDIDATES, PROCESSED_DIR
from download_data import download_broiler_data


def find_raw_file() -> Path:
    for p in RAW_CANDIDATES:
        if p.exists():
            return p

    print("Base não encontrada em data/raw/. Tentando baixar automaticamente...")
    download_broiler_data(force=False)

    for p in RAW_CANDIDATES:
        if p.exists():
            return p

    raise FileNotFoundError(
        "Base não encontrada. Coloque chicken_demand.csv, chicken_demand.dta "
        "ou chicken_demand.parquet em data/raw/."
    )


def clean_names(columns):
    return [str(c).strip().lower().replace(" ", "_") for c in columns]


def read_any(path: Path) -> pd.DataFrame:
    suffix = path.suffix.lower()
    if suffix == ".csv":
        return pd.read_csv(path)
    if suffix == ".dta":
        return pd.read_stata(path)
    if suffix == ".parquet":
        return pd.read_parquet(path)
    raise ValueError(f"Formato não suportado: {suffix}")


def prepare_chicken_demand(df_raw: pd.DataFrame) -> pd.DataFrame:
    df = df_raw.copy()
    df.columns = clean_names(df.columns)

    required = ["q", "y", "pchick", "pbeef", "pcor", "cpi", "time"]
    missing = [v for v in required if v not in df.columns]
    if missing:
        raise ValueError(f"Variáveis ausentes na base: {missing}")

    df = df.rename(columns={"q": "q_raw", "y": "income_real"})

    if "pc" in df.columns:
        df["price_chick_real"] = df["pc"]
    else:
        df["price_chick_real"] = df["pchick"] / df["cpi"]

    if "pb" in df.columns:
        df["price_beef_real"] = df["pb"]
    else:
        df["price_beef_real"] = df["pbeef"] / df["cpi"]

    df["price_corn_real"] = df["pcor"] / df["cpi"]

    df["qc"] = np.log(df["q_raw"])
    df["pf"] = np.log(df["price_chick_real"])
    df["y"] = np.log(df["income_real"])
    df["pb"] = np.log(df["price_beef_real"])
    df["pc"] = np.log(df["price_corn_real"])

    df = df.sort_values("time").reset_index(drop=True)

    df["pc2"] = df["pc"] ** 2
    df["pc3"] = df["pc"] ** 3
    df["pc_l1"] = df["pc"].shift(1)
    df["pc2_l1"] = df["pc_l1"] ** 2
    df["exp_pc"] = np.exp(df["pc"])
    df["exp_pc2"] = np.exp(df["pc"] ** 2)
    df["exp_pc3"] = np.exp(df["pc"] ** 3)
    df["exp_pc_l1"] = np.exp(df["pc_l1"])
    df["exp_pc2_l1"] = np.exp(df["pc_l1"] ** 2)

    base_vars = ["qc", "pf", "y", "pb", "pc"]
    df = df.replace([np.inf, -np.inf], np.nan)
    df = df.dropna(subset=base_vars)

    return df


def main() -> pd.DataFrame:
    raw_path = find_raw_file()
    print(f"Lendo base: {raw_path}")
    raw = read_any(raw_path)
    df = prepare_chicken_demand(raw)

    out_csv = PROCESSED_DIR / "chicken_demand_processed.csv"
    out_parquet = PROCESSED_DIR / "chicken_demand_processed.parquet"
    df.to_csv(out_csv, index=False)
    df.to_parquet(out_parquet, index=False)

    print(f"Base processada salva em: {out_csv}")
    return df


if __name__ == "__main__":
    main()
