#!/bin/bash

# Espera o MySQL iniciar completamente
# (Você pode usar uma ferramenta como wait-for-it.sh para uma solução mais robusta)
echo "Aguardando o MySQL..."
sleep 20

# Executa os scripts na ordem correta
echo "Iniciando a extração para a camada Bronze..."
python3 ./BRONZE/extracao.py

echo "Iniciando a transformação para a camada Silver..."
python3 ./SILVER/silver_tratamento.py

echo "Processo concluído."