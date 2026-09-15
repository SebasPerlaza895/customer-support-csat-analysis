"""
Exporta clean_customer_support a CSV para que Power BI lo consuma
directamente (evita depender del driver ODBC de SQLite).
"""
import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "data" / "customer_support.db"
OUT_PATH = ROOT / "powerbi" / "data" / "clean_customer_support.csv"

OUT_PATH.parent.mkdir(parents=True, exist_ok=True)

with sqlite3.connect(DB_PATH) as conn:
    df = pd.read_sql("SELECT * FROM clean_customer_support", conn)

df.to_csv(OUT_PATH, index=False)
print(f"Exportadas {len(df)} filas a {OUT_PATH}")
