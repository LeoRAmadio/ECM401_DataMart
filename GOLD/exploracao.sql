USE nasa_cmaps;

-- Qual o status geral de saúde (média do sensor) por frota e por tipo de configuração? E qual a média geral?
-- Calcula a média de sensores de temperatura (sensor2) e pressão (sensor7), 
-- agrupados por Frota (fd_id) e Configuração (setting_id). 

SELECT
    m.fd_id AS Frota_ID,
    cfg.setting_id AS Configuracao_ID,
    
    -- Métricas
    AVG(f.sensor2) AS media_temp_saida_hp,
    AVG(f.sensor7) AS media_pressao_saida_hp,
    COUNT(*) AS total_leituras
FROM 
    fact_leitura_ciclo f
JOIN 
    dim_motor m ON f.unit_id_fk = m.unit_id
JOIN 
    dim_configuracao cfg ON f.setting_id_fk = cfg.setting_id
GROUP BY 
    m.fd_id, cfg.setting_id WITH ROLLUP;



-- Quais são os motores específicos que apresentam o maior risco? (Usando a leitura máxima de um sensor de pressão como proxy para "risco").
-- Identifica o estresse máximo (leitura máxima do sensor 11) para cada motor. 
-- Em seguida, usa DENSE_RANK() para criar um ranking dos motores com maior risco, 
-- particionado (agrupado) por cada frota.

WITH MotorMaxEstresse AS (
    SELECT 
        m.fd_id AS Frota_ID,
        m.motor_nr AS Motor_NR,
        MAX(f.sensor11) AS max_pressao_queimador
    FROM 
        fact_leitura_ciclo f
    JOIN 
        dim_motor m ON f.unit_id_fk = m.unit_id
    GROUP BY 
        m.fd_id, m.motor_nr
)
SELECT
    Frota_ID,
    Motor_NR,
    max_pressao_queimador,
    DENSE_RANK() OVER (
        PARTITION BY Frota_ID 
        ORDER BY max_pressao_queimador DESC
    ) AS Ranking_Risco_Por_Frota
FROM 
    MotorMaxEstresse
ORDER BY 
    Frota_ID, Ranking_Risco_Por_Frota;



-- Qual a taxa de degradação? (Comparando a leitura de um sensor com a leitura do ciclo anterior).
-- Calcula a variação 'ciclo a ciclo' (delta) do sensor 4. 
-- A função LAG() busca o valor do ciclo anterior para cada motor (PARTITION BY), 
-- permitindo visualizar 'saltos' de degradação ao longo do tempo.

SELECT 
    m.fd_id AS Frota_ID,
    m.motor_nr AS Motor_NR,
    c.cycle_nr AS Ciclo,
    
    LAG(f.sensor4, 1, f.sensor4) OVER (
        PARTITION BY f.unit_id_fk 
        ORDER BY c.cycle_nr ASC
    ) AS leitura_anterior_s4,
    
    (f.sensor4 - LAG(f.sensor4, 1, f.sensor4) OVER (
        PARTITION BY f.unit_id_fk 
        ORDER BY c.cycle_nr ASC
    )) AS delta_degradacao_s4
FROM 
    fact_leitura_ciclo f
JOIN 
    dim_motor m ON f.unit_id_fk = m.unit_id
JOIN 
    dim_ciclo c ON f.cycle_id_fk = c.cycle_id;


-- Para um motor, quais sensores estão anômalos? (Comparando a leitura atual com a leitura do primeiro ciclo).
-- Compara a leitura atual do sensor 7 com a sua leitura inicial (no primeiro ciclo). 
-- A função FIRST_VALUE() 'fixa' o valor do ciclo 1 para cada motor, 
-- permitindo visualizar o 'desvio' ou 'deriva' do sensor ao longo do tempo.
SELECT 
    m.fd_id AS Frota_ID,
    m.motor_nr AS Motor_NR,
    c.cycle_nr AS Ciclo,
    f.sensor7 AS leitura_atual_s7,
    
    FIRST_VALUE(f.sensor7) OVER (
        PARTITION BY f.unit_id_fk 
        ORDER BY c.cycle_nr ASC
    ) AS leitura_inicial_s7,
    
    (f.sensor7 - FIRST_VALUE(f.sensor7) OVER (
        PARTITION BY f.unit_id_fk 
        ORDER BY c.cycle_nr ASC
    )) AS desvio_do_inicio_s7
FROM 
    fact_leitura_ciclo f
JOIN 
    dim_motor m ON f.unit_id_fk = m.unit_id
JOIN 
    dim_ciclo c ON f.cycle_id_fk = c.cycle_id;
    


-- Para um motor, quais sensores estão apresentando o comportamento mais anômalo? (Identificando os 3 piores ciclos com base na temperatura do óleo).
-- Identifica os 3 piores ciclos (com a maior temperatura de óleo, sensor 14) para cada motor. 
-- A função RANK() é usada para encontrar esses picos de anomalia, 
-- que são então filtrados pelo 'WHERE ranking_anomalia <= 3'.

WITH LeiturasRanqueadas AS (
    SELECT 
        m.fd_id AS Frota_ID,
        m.motor_nr AS Motor_NR,
        c.cycle_nr AS Ciclo,
        f.sensor14 AS temp_oleo,
        
        RANK() OVER (
            PARTITION BY f.unit_id_fk
            ORDER BY f.sensor14 DESC
        ) AS ranking_anomalia
    FROM 
        fact_leitura_ciclo f
    JOIN 
        dim_motor m ON f.unit_id_fk = m.unit_id
    JOIN 
        dim_ciclo c ON f.cycle_id_fk = c.cycle_id
)

SELECT *
FROM LeiturasRanqueadas
WHERE ranking_anomalia <= 3
ORDER BY 
    Frota_ID, Motor_NR, ranking_anomalia;




