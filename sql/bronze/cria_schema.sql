CREATE DATABASE IF NOT EXISTS nasa_cmaps;
USE nasa_cmaps;

DROP TABLE IF EXISTS bronze_fd00x;

CREATE TABLE bronze_fd00x (
    dataset_id INT,
    unit_nr INT,
    cycle INT,
    setting1 DOUBLE,
    setting2 DOUBLE,
    setting3 DOUBLE,
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
    PRIMARY KEY (dataset_id, unit_nr, cycle)
);
