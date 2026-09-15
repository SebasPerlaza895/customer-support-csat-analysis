"""
Carga el CSV crudo a una base de datos SQLite, sin limpiar nada todavia.
Toda la limpieza se hace despues en SQL (carpeta /sql), para que el
portafolio muestre el trabajo real de limpieza con consultas SQL.
"""
import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / "data" / "raw" / "customer_support_data.csv"
DB_PATH = ROOT / "data" / "customer_support.db"


def main():
    df = pd.read_csv(CSV_PATH)

    # Normalizamos solo los NOMBRES de columna (minusculas, sin espacios).
    # El contenido de los datos se deja intacto: eso se limpia en SQL.
    df.columns = (
        df.columns.str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace("-", "_")
    )

    with sqlite3.connect(DB_PATH) as conn:
        df.to_sql("raw_customer_support", conn, if_exists="replace", index=False)

    print(f"Cargadas {len(df)} filas en {DB_PATH}")
    print("Columnas:", list(df.columns))


if __name__ == "__main__":
    main()
