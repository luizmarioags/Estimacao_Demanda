from __future__ import annotations

from pathlib import Path
from urllib.request import urlretrieve

import pandas as pd

from config import BROILER_URL, RAW_DIR

EXPECTED_COLUMNS = [
    "YEAR", "Q", "Y", "PCHICK", "PBEEF", "PCOR", "PF", "CPI",
    "QPRODA", "POP", "MEATEX", "TIME"
]


def download_broiler_data(force: bool = False) -> Path:
    out_csv = RAW_DIR / "chicken_demand.csv"
    mirror_csv = RAW_DIR / "broiler.csv"
    source_txt = RAW_DIR / "SOURCE_broiler.txt"

    if out_csv.exists() and not force:
        print(f"Base já existe em: {out_csv}")
        return out_csv

    print(f"Baixando base de: {BROILER_URL}")
    tmp = RAW_DIR / "_broiler_download_tmp.csv"
    urlretrieve(BROILER_URL, tmp)

    raw = pd.read_csv(tmp)
    raw.columns = [str(c).upper() for c in raw.columns]

    missing = [c for c in EXPECTED_COLUMNS if c not in raw.columns]
    if missing:
        raise ValueError(f"Download realizado, mas variáveis esperadas ausentes: {missing}")

    raw.to_csv(out_csv, index=False)
    raw.to_csv(mirror_csv, index=False)
    tmp.unlink(missing_ok=True)

    source_txt.write_text(
        "Base: broiler/chicken demand\n"
        f"Fonte baixada: {BROILER_URL}\n"
        "Arquivo operacional do pacote: data/raw/chicken_demand.csv\n"
        "Observação: o pacote constrói qc, pf, y, pb e pc em logs a partir das variáveis brutas.\n",
        encoding="utf-8",
    )

    print(f"Base salva em: {out_csv}")
    return out_csv


def main() -> Path:
    return download_broiler_data(force=False)


if __name__ == "__main__":
    main()
