[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python&style=flat-square)](https://www.python.org) [![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-yellow?logo=microsoft-power-bi&style=flat-square)](https://powerbi.microsoft.com) [![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&style=flat-square)](https://www.mysql.com) [![Apache Spark](https://img.shields.io/badge/Apache%20Spark-3.0-orange?logo=apache-spark&style=flat-square)](https://spark.apache.org)

# Análise BI para Motores Aeronáuticos

Este repositório contém o desenvolvimento de um protótipo de **Business Intelligence (BI)** focado em **Manutenção Preditiva (CBM)** para a gestão da saúde de motores turbofan. O projeto visa transformar dados brutos de sensores em *insights* de negócio valiosos, demonstrando como otimizar operações críticas, aumentar a segurança e gerar economia significativa para a indústria aeronáutica.

> O trabalho foi desenvolvido para aprovação na disciplina ECM401 Banco de Dados, do Instituto Mauá de Tecnologia.

## Integrantes do Grupo 

| Nome | R.A. |
| ---- | ---- |
| André Solano Ferreira Rodrigues Maiolini | 19.02012-0 |
| Durval Consorti Soranz de Barros Santos | 22.01097-0 |
| Leonardo Roberto Amadio | 22.01300-8 |
| Lucas Castanho Paganotto Carvalho | 22.00921-3 |

## 💡 Problema de Negócio e Proposta

O problema de negócio a ser resolvido é o alto custo e a ineficiência associados à manutenção não programada e à manutenção preventiva baseada em cronogramas fixos. A abordagem tradicional, a Manutenção Baseada no Tempo (TBM), é segura, mas inerentemente ineficiente e cara.

Nossa proposta é desenvolver um **Cockpit de Saúde da Frota**:
* ✅ **Sistema de BI** que serve como prova de conceito (proof of concept) de um DataMart para um dashboard.
* ✈️ **Objetivo de Negócio:** Transformar dados brutos de sensores em indicadores acionáveis, permitindo decisões proativas para aumentar a segurança, reduzir custos com manutenção não programada e otimizar a disponibilidade da frota.
* 📉 **Relatórios da indústria sugerem que a manutenção preditiva pode reduzir custos gerais de manutenção em 15-20% e diminuir paradas não planejadas em até 50%**.

## ⚙️ Arquitetura e Componentes

O projeto implementa uma solução de BI completa, que inclui modelagem operacional (OLTP), modelagem dimensional (DataMart), e a etapa de ETL.

| Componente | Descrição |
| :--- | :--- |
| **Dataset Fonte** | [**NASA Turbofan Jet Engine Data Set**](https://www.kaggle.com/datasets/behrad3d/nasa-cmaps) (C-MAPSS) da NASA - obtido através da plataforma [Kaggle](https://www.kaggle.com/). É um dataset público considerado um padrão para o desenvolvimento de sistemas de prognóstico. |
| **Base OLTP** | Modelagem e implementação da base de dados operacional em **PostgreSQL** a partir dos dados brutos. |
| **DataMart** | Construção de um **Modelo Dimensional (Star Schema)**. |
| **Processo ETL** | Desenvolvimento do processo de **Extração, Transformação e Carga (ETL)** para popular o DataMart. |
| **Consultas Analíticas** | Elaboração de consultas complexas com **funções de janela** (`RANK`, `LEAD`, etc.) para extrair *insights* estratégicos do DataMart. |
| **Dashboard** | Construção de um dashboard interativo em **Power BI** que apresente os resultados de forma clara e acionável para um **gestor de engenharia**. |

## ❓ Perguntas de Negócio a Serem Respondidas

A arquitetura de BI proposta deverá permitir análises que respondam a perguntas críticas para a gestão de engenharia e operações:

| ID | Funções     | Pergunta de Negócio Respondida                               | Dimensões Analisadas         | 
|:--:| :---------: | :----------------------------------------------------------- | :--------------------------- |
| 1  | ROLLUP      | Qual a temperatura média global e por subnível de altitude?  | "Cenário, Altitude"          |
| 2  | RANK        | Quem são os motores mais duráveis de cada cenário?           | "Cenário, Motor"             |
| 3  | LAG         | Qual o impacto térmico incremental ao subir a potência?      | "Cenário, Potência (TRA)"    |
| 4  | FIRST_VALUE | Qual o desvio de performance em relação ao motor ideal?      | "Cenário, Motor"             |
| 5  | DENSE_RANK  | Quais zonas de altitude causam maior rotação?                | "Cenário, Faixa de Altitude" |
| 6  | ROLLUP      | Qual o ciclo de falha médio para cada configuração?          | "Cenário, Número de Ciclo"   |


## 🚀 Tecnologias

* **Containerização:** Docker, Docker Compose
* **Modelagem de Dados:** Star Schema (DataMart)
* **Banco de Dados:** MySQL (OLTP e DataMart)
* **Processamento ETL:**  Python, Pandas, Apache Spark (via PySpark)
* **Visualização/BI:** Power BI 

## 📦 Estrutura repositório

A estrutura do repositório é dividida em:

- `src/` : Código-fonte Python para ETL (contém `bronze/` e `silver/`).
- `data/` : Local para datasets brutos (arquivos brutos `train_FD*.txt` aqui).
- `sql/`  : Scripts SQL organizados por camada (`bronze/`, `silver/`, `gold/`).
- `docs/` : Fonte LaTeX do relatório para entrega como para aprovação na disciplina.


## 🛠️ Como Executar o Projeto

O projeto é completamente orquestrado com Docker Compose. Siga os passos abaixo para executar o pipeline completo.

* **Pré-requisitos**: Docker Desktop instalado e em execução na sua máquina.

### 1. Configuração do Ambiente

Na raiz do projeto, crie um arquivo chamado `.env` e copie o conteúdo abaixo para ele. Este arquivo fornecerá as credenciais de acesso para o banco de dados.

```
DB_HOST=mysql-db
DB_USER=user
DB_PASSWORD=password
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=nasa_cmaps
```

### 2. Executando o Pipeline ETL

Abra um terminal na pasta raiz do projeto (onde o arquivo `docker-compose.yml` está localizado) e execute o seguinte comando:
```bash
docker-compose up --build
```

Este comando irá:
1. Construir a imagem Docker da aplicação, instalando Java, Python e as dependências do Spark;
2. Iniciar um contêiner para o banco de dados MySQL e criar os schemas das tabelas;
3. Iniciar o contêiner da aplicação, que executará os scripts `extracao.py` e `silver_tratamento.py` em sequência, populando as tabelas Bronze e Silver;

### 3. Verificando o Resultado

Após a execução, você pode se conectar ao banco de dados MySQL para verificar se as tabelas foram populadas. Use um cliente de banco de dados como MySQL Workbench com os seguintes parâmetros:

| Parâmetro | Valor |
|-------|-----------|
| Host | localhost |
| Porta | 3307 |
| Database | nasa_cmaps |
| Usuário | user |
| Senha | password |

Execute uma consulta como: `SELECT COUNT(*) FROM fact_leitura_ciclo;` para confirmar.

### 4. Parando o Ambiente

Para parar e remover todos os contêineres e redes criadas, pressione `Ctrl + C` no terminal onde o compose está rodando, ou abra um novo terminal e execute:
```bash
docker-compose down
```