# %% LIBRARY
import argparse
import datetime
from tqdm import tqdm
import pandas as pd
import sqlalchemy

# %% FUNCTIONS

def read_query(path: str):
    with open(path, encoding="utf-8") as open_file:
        query = open_file.read()
    return query

def date_range(start, stop, monthly=False):
    dates = []
    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')

    if monthly:
        return [i for i in dates if i.endswith('01')]

    return dates

def exec_query(table, db_origin, db_target, dt_start, dt_stop, monthly):
    engine_app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    engine_analytical = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")

    query = read_query(f"../query/{table}.sql")
    dates = date_range(dt_start, dt_stop, monthly)

    for i in tqdm(dates):
        with engine_analytical.connect() as conn:
            try:
                query_delete = f"DELETE FROM {table} WHERE DtRef = date('{i}', '-1 day')"
                conn.execute(sqlalchemy.text(query_delete))
                conn.commit()
            except Exception as e:
                print(e)

        query_format = query.format(date=i)
        df = pd.read_sql(query_format, engine_app)
        df.to_sql(f"{table}", engine_analytical, index=False, if_exists="append")

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('--db_origin', choices=['loyalty-system','education-plataform', 'analytics'], 
                        default='loyalty-system')
    
    parser.add_argument('--db_target', choices=['analytics'], default='analytics')
    parser.add_argument('--table', type=str, help="Tabela que será processada com o mesmo nome do arquivo")

    now = datetime.datetime.now().strftime("%Y-%m-%d")
    parser.add_argument('--start', type=str, default=now)
    parser.add_argument('--stop', type=str, default=now)
    parser.add_argument('--monthly', action='store_true')
    args = parser.parse_args()

    exec_query(args.table, args.db_origin, args.db_target, args.start, args.stop, args.monthly)

if __name__ == "__main__":
    main()