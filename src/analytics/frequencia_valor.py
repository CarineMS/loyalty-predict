# %% LIBRARY
import os
import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt
import seaborn as sns

from sklearn import cluster, preprocessing


# %% CONFIG
os.environ["OMP_NUM_THREADS"] = "3"
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

# %% FUNCTIONS
def read_query(path: str):
    with open(path, encoding="utf-8") as open_file:
        query = open_file.read()
    return query

# READ QUERY
query = read_query("../query/frequencia_valor.sql")

# %%
df = pd.read_sql(query, engine)
df = df[df['qtdePontosPos']<7000] # OUTLIER SISTEMICO: BUG


# %%  Plotting without outlier
plt.plot(df['qtdeFrequencia'], df['qtdePontosPos'], 'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.show()


# %% Clustering

minmax = preprocessing.MinMaxScaler()
X = minmax.fit_transform(df[['qtdeFrequencia','qtdePontosPos']])

kmean = cluster.KMeans(
    n_clusters=5, 
    random_state=42, 
    max_iter=1000)
kmean.fit(X)

df.loc[:, 'cluster'] = kmean.labels_
# print(df.groupby(by='cluster')['IdCliente'].count())

# %%
sns.scatterplot(
    data=df,
    x='qtdeFrequencia',
    y='qtdePontosPos',
    hue='cluster',
    palette='deep'
)
plt.hlines(y=1500, xmin=0, xmax=25, colors='magenta')
plt.hlines(y=750, xmin=0, xmax=25, colors='magenta')

plt.vlines(x=4, ymin=0, ymax=750, colors='magenta')
plt.vlines(x=10, ymin=0, ymax=3000, colors='magenta')

plt.grid()


# %%
sns.scatterplot(
    data=df,
    x='qtdeFrequencia',
    y='qtdePontosPos',
    hue='descCluster',
    palette='deep'
)

plt.grid()


# %% Atribuir pontos