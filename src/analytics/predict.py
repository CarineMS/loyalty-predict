# %%

import pandas as pd
import sqlalchemy

conn = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

model = pd.read_pickle("..\..\data\model\model_fiel.pkl")

# %%

data = pd.read_sql("SELECT * FROM abt_fiel", conn)

predict = model['model'].predict_proba(data[model["features"]])[:,1]

data['predict'] = predict
data