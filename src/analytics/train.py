# %%
import pandas as pd
import sqlalchemy

from sklearn import model_selection 

# %% CONFIG
conn = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")
# %%

# SAMPLE - IMPORT DOS DADOS
df = pd.read_sql("abt_fiel", conn)

# %%

# SAMPLE - OOT - OUT OF TIME 
df_oot = df[df['dtRef'] == df['dtRef'].max()].reset_index(drop=True)


# %%

# SAMPLE - TREINO E TESTE
target = 'flFiel'
features = df.columns.tolist()[3:]

df_train_test = df[df['dtRef']<df['dtRef'].max()].reset_index(drop=True)

y = df_train_test[target]   # isso é um pd.Series (vetor)
X = df_train_test[features] # isso é um pd.DataFrame (matriz)

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
)

print(f"Base Treino: {y_train.shape[0]} Unid. | Tx. Target {100*y_train.mean():.2f}%")
print(f"Base Teste: {y_test.shape[0]} Unid. | Tx. Target {100*y_test.mean():.2f}%")