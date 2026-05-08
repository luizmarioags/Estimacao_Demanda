from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
TABLE_DIR = ROOT / "output" / "tables"
FIG_DIR = ROOT / "output" / "figures"
LOG_DIR = ROOT / "output" / "logs"

for d in [RAW_DIR, PROCESSED_DIR, TABLE_DIR, FIG_DIR, LOG_DIR]:
    d.mkdir(parents=True, exist_ok=True)

BROILER_URL = "https://mitocw.ups.edu.ec/courses/economics/14-271-industrial-organization-i-fall-2005/assignments/broiler.csv"

RAW_CANDIDATES = [
    RAW_DIR / "chicken_demand.csv",
    RAW_DIR / "chicken_demand.dta",
    RAW_DIR / "chicken_demand.parquet",
]

INSTRUMENT_SETS = {
    "Z1": ["pc"],
    "Z2": ["pc", "pc2"],
    "Z3": ["pc", "pc2", "pc3"],
    "Z4": ["pc_l1"],
    "Z5": ["pc_l1", "pc2_l1"],
    "Z6": ["exp_pc"],
    "Z7": ["exp_pc", "exp_pc2"],
    "Z8": ["exp_pc", "exp_pc2", "exp_pc3"],
    "Z9": ["exp_pc_l1"],
    "Z10": ["exp_pc_l1", "exp_pc2_l1"],
}
