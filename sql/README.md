# 🗄️ Scripts SQL 

Este diretório organiza todos os scripts de banco de dados seguindo a lógica da Medallion Architecture (Bronze, Silver, Gold). Aqui residem as definições de estrutura (DDL) e as consultas analíticas (DQL).

# 📂 Organização por Camadas

## 🥉 `bronze/`

Scripts responsáveis pela estrutura inicial que recebe os dados brutos.

- `cria_schema.sql`: Script de inicialização do container. Cria o banco de dados `nasa_cmaps` e usuários de acesso.
- `script_oltp.sql`: Define a tabela transacional bruta (ex: raw_sensor_data) que espelha a estrutura dos arquivos de texto, otimizada para escrita rápida (Ingestão).

## 🥈 `silver/` 

Scripts que definem a modelagem dimensional (Star Schema).

- `silver_script.sql`: Contém os comandos CREATE TABLE para:
    - **Dimensões**: dim_motor (unidades), dim_configuracao (configurações operacionais), dim_ciclo (ciclos).
    - **Fatos**: fact_leitura_sensor (medições granulares).

## 🥇 `gold/`

Scripts de exploração para implementação no BI (*Business Intelligence*).

- `exploracao.sql`: Contém queries analíticas (*Window Functions*) que analisam as perguntas de negócio do projeto.

# 🔄 Execução Automática

Os scripts das pastas bronze e silver são mapeados no docker-compose.yml para execução automática na inicialização do container MySQL (entrypoint), garantindo que o banco esteja sempre com a estrutura correta antes da execução do Python.

---
