import sqlite3
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "data" / "customer_support.db"
conn = sqlite3.connect(DB_PATH)

df = pd.read_sql("SELECT * FROM clean_customer_support", conn)
print(df.shape)
print(df.head())

print(df.info())
print(df["csat_score"].value_counts().sort_index())

print(df.groupby("channel_name")["csat_score"].mean().sort_values(ascending=False))

print(df.groupby("agent_shift")["csat_score"].mean().sort_values(ascending=False))

print(df.groupby("tenure_bucket")["csat_score"].mean().sort_values(ascending=False))

print(pd.crosstab(df["agent_shift"], df["tenure_bucket"], normalize="index"))

df.groupby("channel_name")["csat_score"].mean().sort_values().plot(kind="barh")
plt.title("CSAT promedio por canal")
plt.xlabel("CSAT promedio")
plt.tight_layout()
plt.savefig("reports/figures/csat_by_channel.png", dpi=150)
plt.show()