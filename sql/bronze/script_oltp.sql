USE nasa_cmaps;

DROP TABLE IF EXISTS TAB_LEITURA_CICLO_OLTP;
DROP TABLE IF EXISTS TAB_MOTOR_OLTP;
DROP TABLE IF EXISTS TAB_CONFIGURACAO_OLTP;

CREATE TABLE TAB_MOTOR_OLTP AS
SELECT DISTINCT
    dataset_id,
    unit_nr
FROM bronze_fd00x;

ALTER TABLE TAB_MOTOR_OLTP
ADD PRIMARY KEY (dataset_id, unit_nr);

CREATE TABLE TAB_CONFIGURACAO_OLTP AS
SELECT DISTINCT
    setting1,
    setting2,
    setting3
FROM bronze_fd00x;

ALTER TABLE TAB_CONFIGURACAO_OLTP
ADD PRIMARY KEY (setting1, setting2, setting3);

CREATE TABLE TAB_LEITURA_CICLO_OLTP AS
SELECT
    dataset_id,
    unit_nr,
    cycle,
    setting1,
    setting2,
    setting3,
    sensor1,
    sensor2,
    sensor3,
    sensor4,
    sensor5,
    sensor6,
    sensor7,
    sensor8,
    sensor9,
    sensor10,
    sensor11,
    sensor12,
    sensor13,
    sensor14,
    sensor15,
    sensor16,
    sensor17,
    sensor18,
    sensor19,
    sensor20,
    sensor21
FROM bronze_fd00x;

ALTER TABLE TAB_LEITURA_CICLO_OLTP
ADD PRIMARY KEY (dataset_id, unit_nr, cycle);

ALTER TABLE TAB_LEITURA_CICLO_OLTP
ADD CONSTRAINT FK_LEITURA_MOTOR
FOREIGN KEY (dataset_id, unit_nr)
REFERENCES TAB_MOTOR_OLTP(dataset_id, unit_nr);

ALTER TABLE TAB_LEITURA_CICLO_OLTP
ADD CONSTRAINT FK_LEITURA_CONFIG
FOREIGN KEY (setting1, setting2, setting3)
REFERENCES TAB_CONFIGURACAO_OLTP(setting1, setting2, setting3);
