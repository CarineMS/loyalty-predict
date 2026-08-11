# # Define o ambiente Conda
CONDA_ENV=loyalty-predict

# # Define o diretório do ambiente virtual
# VENV_DIR=.venv

# # Configura o ambiente virtual
# .PHONY: setup
# setup:
# 	rm -rf $(VENV_DIR)
# 	@echo "Criando ambiente virtual..."
# 	python3 -m venv $(VENV_DIR)
# 	@echo "Ativando ambiente virtual e instalando dependências..."
# 	. $(VENV_DIR)/bin/activate && \
# 	pip install pipreqs && \
#  	pipreqs src/ --force --savepath requirements.txt && \
# 	pip install -r requirements.txt

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


# # Executa os scripts
# .PHONY: run
# run:
# 	@echo "Ativando ambiente virtual..."
# 	. $(VENV_DIR)/bin/activate  && \
# 	@echo "Executando scripts de engenharia..."
# 	cd src/engineering && \
# 	python get_data.py  && \
# 	cd ../analytics && \
# 	python pipeline_analytics.py

# # Alvo padrão
# .PHONY: all
# all: setup run