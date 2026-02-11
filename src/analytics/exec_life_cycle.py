# %% LIBRARY

import datetime
from tqdm import tqdm

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

# %% FUNCTIONS

def read_query(path: str):
    with open(path, encoding="utf-8") as open_file:
        query = open_file.read()
    return query

def date_range(start, stop):
    dates = []
    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')

    return dates

# %% READ QUERY
query = read_query("../query/life_cycle.sql")

# %% CONFIG ENGINE
# engine - db de aplicação (possibilidade de ser reescrito)
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# engine -  db de contexto/aplicação (sumarizando como uma entidade - n está no nivel transacional)
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %% TRANSFER DATA BETWEEN DATABASES
# LOAD DATA FROM APLICATION.DB AND WRITE TO ANALYTICAL.DB

dates = date_range('2024-09-01', '2025-10-01')

for i in tqdm(dates):
    with engine_analytical.connect() as conn:
        try:
            query_delete = f"DELETE FROM life_cycle WHERE DtRef = date('{i}', '-1 day')"
            conn.execute(sqlalchemy.text(query_delete))
            conn.commit()
        except Exception as e:
            print(e)

    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists="append")
