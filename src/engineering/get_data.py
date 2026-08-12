# %%
from pathlib import Path
import shutil

import dotenv
from kaggle import api
import shutil

dotenv.load_dotenv(".env")

datasets = [
    'teocalvo/teomewhy-loyalty-system',
    'teocalvo/teomewhy-education-platform'
]

for d in datasets:
    dataset_name = d.split("teomewhy-")[-1]
    print(dataset_name)

    path = Path("data") / dataset_name / "database.db"
    path.parent.mkdir(parents=True, exist_ok=True)
    api.dataset_download_file(d, "database.db")
    shutil.move("database.db", path)