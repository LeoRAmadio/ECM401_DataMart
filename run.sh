#!/bin/bash

# Espera o MySQL iniciar completamente
echo "Aguardando o MySQL..."
sleep 20

# Executa os scripts da arq medalhao na ordem correta

## BRONZE
echo "Iniciando a extração para a camada Bronze..."
python3 ./BRONZE/extracao.py

## SILVER
echo "Iniciando a transformação para a camada Silver..."
python3 ./SILVER/silver_tratamento.py

## GOLD
echo "Camada Gold - [em desenvolvimento...]"

# Finaliza o script
echo "Processo concluído."