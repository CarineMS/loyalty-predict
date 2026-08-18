# %% 
import requests
import sqlalchemy
import pandas as pd
import json


db_path = r"C:\Users\ninam\dev\loyalty-predict\loyalty-predict\data\analytics\database.db"

conn = sqlalchemy.create_engine(f"sqlite:///{db_path}")

data = pd.read_sql("SELECT * FROM fs_all LIMIT 1", conn)
data = {"data":data.to_dict(orient='records')[0]}
print(data)

resp = requests.post("http://localhost:5001/predict", json=data)
resp.json()
# %%
data = pd.read_sql("SELECT * FROM fs_all LIMIT 10", conn).to_json(orient='records')
data = {'data':json.loads(data)}
data

# %%
resp = requests.post("http://localhost:5001/predict_many", json=data)
resp.json()