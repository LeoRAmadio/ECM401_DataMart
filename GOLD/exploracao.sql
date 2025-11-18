--Consulta 1: Baseline e Desvio Médio
WITH Ranked_Data AS (
    SELECT
        T2.fd_id,
        T3_config.setting1,
        T1.sensor4,
        T2.motor_nr,
        T3_ciclo.cycle_nr,
        FIRST_VALUE(T1.sensor4) OVER (
            PARTITION BY T2.motor_nr
            ORDER BY T3_ciclo.cycle_nr ASC
        ) AS sensor4_baseline
    FROM
        fact_leitura_ciclo T1
    JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
    JOIN dim_configuracao T3_config ON T1.setting_id_fk = T3_config.setting_id
    JOIN dim_ciclo T3_ciclo ON T1.cycle_id_fk = T3_ciclo.cycle_id
)
SELECT
    COALESCE(T1.fd_id, 0) AS fd_id,
    COALESCE(CAST(T1.setting1 AS CHAR), 'Total Cenário') AS setting1,
    COUNT(*) AS contagem_leituras,
    AVG(T1.sensor4 - T1.sensor4_baseline) AS media_desvio_baseline_s4,
    AVG(T1.sensor4) AS media_total_s4
FROM Ranked_Data T1
GROUP BY T1.fd_id, T1.setting1
WITH ROLLUP;

--Consulta 2: Ranking de Risco

WITH Max_Cycle_Per_Unit AS (
    SELECT
        T2.fd_id,
        T2.motor_nr,
        MAX(T3.cycle_nr) AS max_cycle
    FROM
        fact_leitura_ciclo T1
    JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
    JOIN dim_ciclo T3 ON T1.cycle_id_fk = T3.cycle_id
    GROUP BY 1, 2
)
SELECT
    T1.fd_id,
    T1.motor_nr,
    T1.max_cycle,
    RANK() OVER (
        PARTITION BY T1.fd_id
        ORDER BY T1.max_cycle ASC
    ) AS rank_risco,
    DENSE_RANK() OVER (
        PARTITION BY T1.fd_id
        ORDER BY T1.max_cycle ASC
    ) AS dense_rank_risco,
    ROW_NUMBER() OVER (
        PARTITION BY T1.fd_id
        ORDER BY T1.max_cycle ASC, T1.motor_nr ASC
    ) AS row_num_prioridade
FROM
    Max_Cycle_Per_Unit T1
ORDER BY fd_id, rank_risco;

--Consulta 3: Desvio e Projeção Temporal

SELECT
    T2.fd_id,
    T2.motor_nr,
    T3.cycle_nr,
    T1.sensor13 AS sensor13_atual,
    FIRST_VALUE(T1.sensor13) OVER (
        PARTITION BY T2.fd_id, T2.motor_nr
        ORDER BY T3.cycle_nr ASC
    ) AS sensor13_baseline,
    T1.sensor13 - FIRST_VALUE(T1.sensor13) OVER (
        PARTITION BY T2.fd_id, T2.motor_nr
        ORDER BY T3.cycle_nr ASC
    ) AS desvio_baseline_s13,
    LEAD(T1.sensor13, 1) OVER (
        PARTITION BY T2.fd_id, T2.motor_nr
        ORDER BY T3.cycle_nr
    ) - T1.sensor13 AS variacao_proximo_ciclo_s13
FROM
    fact_leitura_ciclo T1
JOIN
    dim_motor T2 ON T1.unit_id_fk = T2.unit_id
JOIN
    dim_ciclo T3 ON T1.cycle_id_fk = T3.cycle_id
ORDER BY 1, 2, 3;

--Consulta 4: Correlação de Taxas de Degradação

SELECT
    T2.fd_id,
    T2.motor_nr,
    T3.cycle_nr,
    T1.sensor6 - LAG(T1.sensor6, 1, T1.sensor6) OVER (
        PARTITION BY T2.fd_id, T2.motor_nr
        ORDER BY T3.cycle_nr
    ) AS variacao_s6,
    T1.sensor11 - LAG(T1.sensor11, 1, T1.sensor11) OVER (
        PARTITION BY T2.fd_id, T2.motor_nr
        ORDER BY T3.cycle_nr
    ) AS variacao_s11
FROM
    fact_leitura_ciclo T1
JOIN
    dim_motor T2 ON T1.unit_id_fk = T2.unit_id
JOIN
    dim_ciclo T3 ON T1.cycle_id_fk = T3.cycle_id
ORDER BY 1, 2, 3;

--Consulta 5: Ciclo de Falha Médio Esperado (KPI)
SELECT
    COALESCE(T2.fd_id, 0) AS fd_id,
    COUNT(T2.motor_nr) AS total_motores_no_cenario,
    AVG(T2.max_cycle) AS ciclo_falha_medio_esperado
FROM (
    SELECT
        T_DIM.fd_id,
        T_DIM.motor_nr,
        MAX(T_CICLO.cycle_nr) AS max_cycle
    FROM
        fact_leitura_ciclo T_FATO
    JOIN dim_motor T_DIM ON T_FATO.unit_id_fk = T_DIM.unit_id
    JOIN dim_ciclo T_CICLO ON T_FATO.cycle_id_fk = T_CICLO.cycle_id
    GROUP BY 1, 2
) AS T2
GROUP BY
    T2.fd_id
WITH ROLLUP;