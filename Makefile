CONDA_ENV=loyalty-predict

.PHONY: setup run all

setup:
	@echo "Instalando dependências..."
	conda run -n $(CONDA_ENV) pip install -r requirements.txt

run:
	@echo "Executando scripts de engenharia..."
	conda run -n $(CONDA_ENV) python src/engineering/get_data.py
	@echo "Executando pipeline de analytics..."
	conda run -n $(CONDA_ENV) python src/analytics/pipeline_analytics.py

all: setup run