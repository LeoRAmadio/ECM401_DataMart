# Cockpit de Saúde da Frota: Análise Preditiva para Manutenção de Motores Aeronáuticos

Este repositório contém o desenvolvimento de um protótipo de **Business Intelligence (BI)** focado em **Manutenção Preditiva (CBM)** para a gestão da saúde de motores turbofan. O projeto visa transformar dados brutos de sensores em *insights* de negócio valiosos, demonstrando como otimizar operações críticas, aumentar a segurança e gerar economia significativa para a indústria aeronáutica.

> O trabalho foi desenvolvido para aprovação na disciplina ECM401 Banco de Dados, do Instituto Mauá de Tecnologia.

## Integrantes do Grupo 

| Nome | R.A. |
| ---- | ---- |
| André Solano F. R. Maiolini | 19.02012-0 |
| Durval Consorti Soranz de Barros Santos | 22.01097-0 |
| Leonardo Roberto Amadio | 22.01300-8 |

## 💡 Problema de Negócio e Proposta

O problema de negócio a ser resolvido é o alto custo e a ineficiência associados à manutenção não programada e à manutenção preventiva baseada em cronogramas fixos. A abordagem tradicional, a Manutenção Baseada no Tempo (TBM), é segura, mas inerentemente ineficiente e cara.

Nossa proposta é desenvolver um **Cockpit de Saúde da Frota**:
* ✅ **Sistema de BI** que serve como prova de conceito (proof of concept) de um DataMart e um dashboard gerencial.
* ✈️ **Objetivo de Negócio:** Transformar dados brutos de sensores em indicadores acionáveis, permitindo decisões proativas para aumentar a segurança, reduzir custos com manutenção não programada e otimizar a disponibilidade da frota.
* 📉 **Relatórios da indústria sugerem que a manutenção preditiva pode reduzir custos gerais de manutenção em 15-20% e diminuir paradas não planejadas em até 50%**.

## ⚙️ Arquitetura e Componentes

O projeto implementa uma solução de BI completa, que inclui modelagem operacional (OLTP), modelagem dimensional (DataMart), e a etapa de ETL.

| Componente | Descrição |
| :--- | :--- |
| **Dataset Fonte** | [**NASA Turbofan Jet Engine Data Set**](https://www.kaggle.com/datasets/behrad3d/nasa-cmaps) (C-MAPSS) da NASA - obtido através da plataforma [Kaggle](https://www.kaggle.com/). É um dataset público considerado um padrão para o desenvolvimento de sistemas de prognóstico. |
| **Base OLTP** | Modelagem e implementação da base de dados operacional em **PostgreSQL** a partir dos dados brutos. |
| **DataMart** | Construção de um **Modelo Dimensional (Star Schema)**. O DataMart é **enriquecido com dimensões de negócio** hipotéticas, mas realistas, como Frota/Cliente e Custo de Manutenção. |
| **Processo ETL** | Desenvolvimento do processo de **Extração, Transformação e Carga (ETL)** para popular o DataMart. |
| **Métrica Chave (RUL)** | **Vida Útil Remanescente (RUL - Remaining Useful Life):** KPI de engenharia que estima o número de ciclos de operação (voos) restantes antes da falha crítica. O ETL **calcula o RUL verdadeiro** usando a fórmula $RUL = Ciclo\_Máximo - Ciclo\_Atual$ para simular um valor fornecido por um sistema de Machine Learning externo. |
| **Consultas Analíticas** | Elaboração de consultas complexas com **funções de janela** (`RANK`, `LEAD`, etc.) para extrair *insights* estratégicos do DataMart. |
| **Dashboard** | Construção de um dashboard interativo em **Power BI** ou **Tableau** que apresente os resultados de forma clara e acionável para um gestor de frota. |

## ❓ Perguntas de Negócio a Serem Respondidas

A arquitetura de BI proposta deverá permitir análises que respondam a perguntas críticas para a gestão de manutenção e operações:

* **Pergunta (1)**: Desvio Médio da Baseline por Configuração e Cenário: Em média, como o desvio do Sensor 4 em relação à sua leitura inicial (baseline) varia entre as diferentes configurações operacionais (setting1) dentro de cada cenário de teste (FD00x)?
    - **Objetivo**: Medir o grau de desgaste cumulativo (media_desvio_baseline_s4) em diferentes condições de voo, fornecendo subtotais hierárquicos para contextualização gerencial (ROLLUP).

* **Pergunta (2)**: Priorização de Inspeção com Base no Risco de Falha Precoce: Qual é o ranking de risco de falha mais precoce para cada motor (motor_nr) dentro de seu respectivo cenário de teste (FD00x)?
    - **Objetivo**: Priorizar a inspeção e manutenção (P3), identificando os motores mais críticos por meio de diferentes classificações de risco (RANK, DENSE_RANK, ROW_NUMBER).

* **Pergunta (3)**: Análise da Tendência de Degradação (Próximo Ciclo): Qual é o desvio cumulativo do Sensor 13 em relação à baseline e qual a variação esperada no próximo ciclo (LEAD) para cada motor?

    - **Objetivo**: Suporte direto à análise de degradação progressiva, combinando o desgaste total (desvio_baseline_s13) com a projeção de tendência imediata (variacao_proximo_ciclo_s13).

* **Pergunta (4)**: Correlação da Taxa de Variação entre Sensores Críticos: Existe uma correlação entre a taxa de variação ciclo-a-ciclo do Sensor 6 (Pressão) e a do Sensor 11 (Temperatura) em cada motor?
    - **Objetivo**: Mapear a interdependência entre subsistemas (P6) ao analisar se o aumento ou diminuição brusca em um sensor é acompanhado pelo outro (LAG).

* **Pergunta (5)**: Ciclo de Falha Médio Esperado (KPI de Confiabilidade): Qual é o Ciclo de Falha Médio Esperado para cada cenário de teste (FD00x), e como isso se compara à média geral da frota?
    - **Objetivo**: Estabelecer um KPI de benchmark de confiabilidade (P5) para que os gestores possam comparar a longevidade esperada em diferentes condições de operação (ROLLUP).

* **Pergunta (6)**: É possível identificar correlação entre sensores específicos antes da falha?
    - **Objetivo**: Objetivo: Permite mapear interdependência entre subsistemas (compressor, turbina, etc.).

* **Pergunta (7)**: Como o comportamento temporal dos sensores evolui nos últimos ciclos antes da falha?
    - **Objetivo**: Suporte direto a análises de degradação progressiva.


## 🚀 Tecnologias

* **Containerização:** Docker, Docker Compose
* **Modelagem de Dados:** Star Schema (DataMart)
* **Banco de Dados:** MySQL (OLTP e DataMart)
* **Processamento ETL:**  Python, Pandas, Apache Spark (via PySpark)
* **Visualização/BI:** Power BI 

## 🛠️ Como Executar o Projeto

O projeto é completamente orquestrado com Docker Compose. Siga os passos abaixo para executar o pipeline completo.

* **Pré-requisitos**: Docker Desktop instaldo e em execução na sua máquina.

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
2. Iniciar um contêiner para o banco de dados MySQL e criar os chemas das tabelas;
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
