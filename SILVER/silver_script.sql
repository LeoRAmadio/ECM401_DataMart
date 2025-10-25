USE nasa_cmaps;

DROP TABLE IF EXISTS dim_motor;
CREATE TABLE dim_motor (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    fd_id INT,  
    motor_nr INT,
    UNIQUE KEY uk_motor (fd_id, motor_nr) 
);

DROP TABLE IF EXISTS dim_configuracao;
CREATE TABLE dim_configuracao (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting1 DOUBLE,
    setting2 DOUBLE,
    setting3 DOUBLE,
    UNIQUE KEY uk_config (setting1, setting2, setting3)
);

DROP TABLE IF EXISTS fact_leitura_ciclo;
CREATE TABLE fact_leitura_ciclo (
    unit_id_fk INT, 
    cycle INT,
    setting_id_fk INT,
    sensor1 DOUBLE,
    sensor2 DOUBLE,
    sensor3 DOUBLE,
    sensor4 DOUBLE,
    sensor5 DOUBLE,
    sensor6 DOUBLE,
    sensor7 DOUBLE,
    sensor8 DOUBLE,
    sensor9 DOUBLE,
    sensor10 DOUBLE,
    sensor11 DOUBLE,
    sensor12 DOUBLE,
    sensor13 DOUBLE,
    sensor14 DOUBLE,
    sensor15 DOUBLE,
    sensor16 DOUBLE,
    sensor17 DOUBLE,
    sensor18 DOUBLE,
    sensor19 DOUBLE,
    sensor20 DOUBLE,
    sensor21 DOUBLE,

    PRIMARY KEY (unit_id_fk, cycle), 
    
    FOREIGN KEY (unit_id_fk) REFERENCES dim_motor(unit_id),
    FOREIGN KEY (setting_id_fk) REFERENCES dim_configuracao(setting_id)
);
