# Cockpit de Saúde da Frota: Análise Preditiva para Manutenção de Motores Aeronáuticos

Este repositório contém o desenvolvimento de um protótipo de **Business Intelligence (BI)** focado em **Manutenção Preditiva (CBM)** para a gestão da saúde de motores turbofan. O projeto visa transformar dados brutos de sensores em *insights* de negócio valiosos, demonstrando como otimizar operações críticas, aumentar a segurança e gerar economia significativa para a indústria aeronáutica.

> O trabalho foi apresentado como aprovação na disciplina ECM401 Banco de Dados, do Instituto Mauá de Tecnologia.

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

* Qual o status geral de saúde da frota de motores, categorizado por nível de risco (Crítico, Observação, Saudável)?
* Quais são os motores específicos que apresentam o maior risco de falha iminente (menor RUL)?
* Existe diferença significativa na taxa de degradação (queda do RUL) entre diferentes frotas de clientes ou regiões operacionais?
* Qual o custo total evitado por meio da realização de manutenções preditivas em comparação com o custo estimado de falhas não programadas?
* Quais parâmetros operacionais (altitude, velocidade, potência) estão mais correlacionados com uma aceleração na degradação do motor?
* Para um motor específico em alerta, quais sensores estão apresentando o comportamento mais anômalo, auxiliando no diagnóstico da causa raiz?

## 🚀 Tecnologias

* **Modelagem de Dados:** Star Schema (DataMart)
* **Banco de Dados:** PostgreSQL (OLTP e DataMart)
* **Processamento:** ETL (Extração, Transformação e Carga)
* **Visualização/BI:** Power BI ou Tableau
