CONDA_ENV=loyalty-predict

.PHONY: setup
setup:
	@echo "Instalando dependências..."
	conda run -n $(CONDA_ENV) pip install -r requirements.txt

.PHONY: collect
collect:
	@echo "Executando scripts de engenharia..."
	conda run -n $(CONDA_ENV) python src/engineering/get_data.py

.PHONY: etl
etl:	
	@echo "Executando pipeline de feature store..."
	conda run -n $(CONDA_ENV) python src/analytics/pipeline_analytics.py

.PHONY: predict
predict:
	@echo "Executando script de predição..."
	cd src/analytics && conda run -n $(CONDA_ENV) python predict_fiel.py

.PHONY: all
all: setup collect etl predict