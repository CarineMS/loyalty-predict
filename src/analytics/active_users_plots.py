# %% LIBRARY
from dotenv import load_dotenv
import os

import pandas as pd
import matplotlib.pyplot as plt

# %% CONFIG
load_dotenv(dotenv_path=".env")
local_address = os.getenv("LOCAL_ADDRESS")

# %%

df_dau = pd.read_csv(
    fr'{local_address}\data\analytics\DAU_versus_DtDia.txt'
)

df_mau = pd.read_csv(
    fr'{local_address}\data\analytics\MAU_versus_DtMes.txt'
)

df_mau4w = pd.read_csv(
    fr'{local_address}\data\analytics\MAU4weeks_versus_DtMes.txt'
)
# %%
# Serie Temporal DtDia Versus DAU
df_dau['data'] = pd.to_datetime(df_dau['DtDia'])
df_dau = df_dau.sort_values('data')

plt.figure(figsize=(12,5))
plt.plot(df_dau['data'], df_dau['DAU'])
plt.xlabel('Data')
plt.ylabel('DAU')
plt.title('DAU versus DtDia')
plt.grid(True)
plt.show()


# %%
# Serie Temporal DtDia Versus MAU
df_mau['data'] = pd.to_datetime(df_mau['DtMes'])
df_mau = df_mau.sort_values('data')

plt.figure(figsize=(12,5))
plt.plot(df_mau['data'], df_mau['MAU'])
plt.xlabel('Data')
plt.ylabel('MAU')
plt.title('MAU versus DtDia')
plt.grid(True)
plt.show()

# %%
df_mau4w.head()
# %%
# Serie Temporal DtDia Versus MAU4week
df_mau4w['data'] = pd.to_datetime(df_mau4w['DtMes'])
df_mau4w = df_mau4w.sort_values('data')

plt.figure(figsize=(12,5))
plt.plot(df_mau4w['data'], df_mau4w['MAU'])
plt.xlabel('Data')
plt.ylabel('MAU')
plt.title('MAU versus DtDia')
plt.grid(True)
plt.show()