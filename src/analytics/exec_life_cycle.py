# %% LIBRARY

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

# %% FUNCTIONS

def read_query(path: str):
    with open(path, encoding="utf-8") as open_file:
        query = open_file.read()
    return query

# %% READ QUERY
query = read_query("../query/life_cycle.sql")

# %% CONFIG ENGINE
# engine - db de aplicação (possibilidade de ser reescrito)
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# engine -  db de contexto/aplicação (sumarizando como uma entidade - n está no nivel transacional)
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %% TRANSFER DATA BETWEEN DATABASES
# LOAD DATA FROM APLICATION.DB AND WRITE TO ANALYTICAL.DB

dates = [
    '2024-03-01',
    '2024-04-01',
    '2024-05-01',
    '2024-06-01',
    '2024-07-01',
    '2024-08-01',
    '2024-09-01',
    '2024-10-01',
    '2024-11-01',
    '2024-12-01',
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01',
    '2025-10-01',
    '2025-11-01',
    '2025-12-01'
]

for i in dates:
    try:
        with engine_analytical.connect() as conn:
            query_delete = f"DELETE FROM life_cycle WHERE DtRef = date('{i}', '-1 day')"
            conn.execute(sqlalchemy.text(query_delete))
            conn.commit()
    except Exception as e:
        print(e)

    print(f'Data analisada: {i}')
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists="append")

# %% VALIDATION TUTORIAL

query_val = read_query("../query/trying_life_cycle.sql")
df_val = pd.read_sql(query_val, engine_analytical)
df_val.head()

# %% ploting
df_pivot = df_val.pivot(index="DtRef", columns="descLifeCycle", values="qtdeCliente")

# Plot
df_pivot.plot(kind="bar", stacked=True, figsize=(10,5))

plt.title("Clientes por LifeCycle")
plt.xlabel("Data de Referência")
plt.ylabel("Quantidade de Clientes")
plt.legend(title="LifeCycle")
plt.tight_layout()
plt.show()

# %%
df_pct = df_pivot.div(df_pivot.sum(axis=1), axis=0) * 100

# Plot
df_pct.plot(kind="bar", stacked=True, figsize=(10,5))

plt.title("Clientes por LifeCycle (%)")
plt.xlabel("Data de Referência")
plt.ylabel("Percentual (%)")
plt.legend(title="LifeCycle")
plt.tight_layout()
plt.show()