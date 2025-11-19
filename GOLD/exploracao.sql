-- +----+-----------------------------------------------------------------------+------------------------------+
-- | ID | Pergunta de Negócio Respondida                                        | Dimensões Analisadas         | 
-- +----+-----------------------------------------------------------------------+------------------------------+
-- | 1  | ROLLUP - Qual a temperatura média global e por subnível de altitude?  | "Cenário, Altitude"          |
-- | 2  | RANK - Quem são os motores mais duráveis de cada cenário?             | "Cenário, Motor"             |
-- | 3  | LAG - Qual o impacto térmico incremental ao subir a potência?         | "Cenário, Potência (TRA)"    |
-- | 4  | FIRST_VALUE - Qual o desvio de performance em relação ao motor ideal? | "Cenário, Motor"             |
-- | 5  | DENSE_RANK- Quais zonas de altitude causam maior estresse de rotação? | "Cenário, Faixa de Altitude" |
-- +----+-----------------------------------------------------------------------+------------------------------+

-- ============================================================================================================
-- CONSULTA 1: Média de Ciclos por Cenário e Configuração de Altitude
-- Função Analítica: ROLLUP
-- Pergunta: Qual a temperatura média global e por subnível de altitude?
-- Dimensões do GROUP BY: fd_id (Cenário), setting1 (Altitude arredondada)
-- ============================================================================================================

SELECT 
    COALESCE(CAST(T2.fd_id AS CHAR), 'Total Geral') AS cenario_teste,
    COALESCE(CAST(ROUND(T3.setting1, 0) AS CHAR), 'Todas Altitudes') AS altitude_ft,
    COUNT(DISTINCT T2.motor_nr) AS qtd_motores,
    ROUND(AVG(T1.sensor4), 2) AS temp_media_lpt
FROM fact_leitura_ciclo T1
JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
JOIN dim_configuracao T3 ON T1.setting_id_fk = T3.setting_id
GROUP BY 
    T2.fd_id, 
    ROUND(T3.setting1, 0) 
WITH ROLLUP;

-- ============================================================================================================
-- CONSULTA 2: Ranking de Confiabilidade
-- Função Analítica: RANK 
-- Pergunta: Quem são os motores mais duráveis de cada cenário?
-- Dimensões do GROUP BY: fd_id (Cenário), motor_nr (Identificador do motor)
-- ============================================================================================================

SELECT 
    T2.fd_id,
    T2.motor_nr,
    MAX(T4.cycle_nr) AS vida_util_total,
    -- Rankeia os motores: 1 = O que durou mais (Melhor), 100 = O que quebrou primeiro (Pior)
    RANK() OVER (
        PARTITION BY T2.fd_id 
        ORDER BY MAX(T4.cycle_nr) DESC
    ) AS ranking_confiabilidade
FROM fact_leitura_ciclo T1
JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
JOIN dim_ciclo T4 ON T1.cycle_id_fk = T4.cycle_id
GROUP BY 
    T2.fd_id, 
    T2.motor_nr;

-- ============================================================================================================
-- CONSULTA 3: Correlação Manete e Temperatura
-- Função Analítica: LAG 
-- Pergunta: Qual o impacto térmico incremental ao subir a potência? 
-- Dimensões do GROUP BY: fd_id (Cenário), setting3 (Manete de Potência)
-- ============================================================================================================

SELECT 
    T_FINAL.fd_id,
    T_FINAL.potencia_manete,
    AVG(T_FINAL.media_temp) AS media_temp_lpt,
    -- Calcula a diferença de temperatura em relação ao degrau anterior de potência
    AVG(T_FINAL.media_temp) - LAG(AVG(T_FINAL.media_temp), 1) OVER (
        PARTITION BY T_FINAL.fd_id 
        ORDER BY T_FINAL.potencia_manete
    ) AS diferenca_para_potencia_anterior
FROM (
    -- Subquery para arredondar a potência antes de agrupar
    SELECT 
        T2.fd_id,
        ROUND(T3.setting3, 1) AS potencia_manete,
        T1.sensor4 AS media_temp
    FROM fact_leitura_ciclo T1
    JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
    JOIN dim_configuracao T3 ON T1.setting_id_fk = T3.setting_id
) AS T_FINAL
GROUP BY 
    T_FINAL.fd_id, 
    T_FINAL.potencia_manete;

-- ============================================================================================================
-- CONSULTA 4: Desvio do Motor Ideal
-- Função Analítica: FIRST_VALUE 
-- Pergunta: Qual o desvio de performance em relação ao motor ideal?
-- Dimensões do GROUP BY: fd_id (Cenário), motor_nr (Identificador do motor)
-- ============================================================================================================

SELECT 
    T2.fd_id,
    T2.motor_nr,
    ROUND(AVG(T1.sensor4), 2) AS temp_media_motor,
    -- Pega a temperatura do motor mais "frio" (saudável) do mesmo cenário
    ROUND(FIRST_VALUE(AVG(T1.sensor4)) OVER (
        PARTITION BY T2.fd_id 
        ORDER BY AVG(T1.sensor4) ASC
    ), 2) AS temp_benchmark_lider,
    -- Calcula o desvio: Quanto meu motor está mais quente que o líder?
    ROUND(AVG(T1.sensor4) - FIRST_VALUE(AVG(T1.sensor4)) OVER (
        PARTITION BY T2.fd_id 
        ORDER BY AVG(T1.sensor4) ASC
    ), 2) AS desvio_do_lider
FROM fact_leitura_ciclo T1
JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
GROUP BY 
    T2.fd_id, 
    T2.motor_nr;

-- ============================================================================================================
-- CONSULTA 5: Altitude vs. Rotação
-- Função Analítica: DENSE_RANK 
-- Pergunta: Quais zonas de altitude causam maior estresse de rotação?
-- Dimensões do GROUP BY: fd_id (Cenário), setting1 (Altitude)
-- ============================================================================================================

SELECT 
    T_FINAL.fd_id,
    ROUND(T_FINAL.altitude_raw, -1) AS faixa_altitude, 
    ROUND(AVG(T_FINAL.sensor9), 2) AS rotacao_media_core,
    DENSE_RANK() OVER (
        PARTITION BY T_FINAL.fd_id 
        ORDER BY AVG(T_FINAL.sensor9) DESC
    ) AS rank_severidade_altitude
FROM (
    SELECT 
        T2.fd_id,
        T3.setting1 AS altitude_raw,
        T1.sensor9
    FROM fact_leitura_ciclo T1
    JOIN dim_motor T2 ON T1.unit_id_fk = T2.unit_id
    JOIN dim_configuracao T3 ON T1.setting_id_fk = T3.setting_id
) AS T_FINAL
GROUP BY 
    T_FINAL.fd_id, 
    ROUND(T_FINAL.altitude_raw, -1);

-- ============================================================================================================