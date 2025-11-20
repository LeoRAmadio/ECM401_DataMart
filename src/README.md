# 🐍 Código Fonte ETL (Extract, Transform, Load)

Este diretório contém os scripts em Python responsáveis por orquestrar o fluxo de dados entre os arquivos brutos e o banco de dados MySQL.

# 🏗️ Estrutura do Pipeline

O pipeline foi desenhado para ser modular, separando a responsabilidade de ingestão (I/O) da responsabilidade de regra de negócio (Transformação).

## 📂 `bronze/` (Load)
Focada na extração e carga inicial (EL).

- `extracao.py`:
    - **Função**: Ler os arquivos de texto (train_FD00*.txt) da pasta `data/bronze/`.
    - **Processo**: Adiciona cabeçalhos aos dados e insere os registros na tabela transacional (**OLTP**) do banco de dados.
    - **Tecnologia**: Utiliza bibliotecas padrão e conectores MySQL para inserção em lote (batch insert) visando performance.

## 📂 `silver/` (Transform)

Focada na limpeza e modelagem dimensional (T).

- `silver_tratamento.py`:
    - **Função**: Ler os dados brutos do banco (Bronze), aplicar limpezas e popular o DataMart (Star Schema).
    - **Processo**: 
        1. Normalização de unidades de medida (se necessário).
        2. Criação de chaves substitutas (Surrogate Keys) para dimensões.
        3. Cálculo de métricas derivadas.
        4. Carga nas tabelas de Fato e Dimensão na camada Silver do banco.

# 📦 Dependências

Os scripts dependem das bibliotecas listadas no arquivo `requirements.txt` na raiz do projeto, principalmente:

- `pandas`: Para manipulação de DataFrames em memória.
- `mysql-connector-python`: Para conexão com o container do banco.