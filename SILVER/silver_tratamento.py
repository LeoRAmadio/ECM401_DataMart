import os
from dotenv import load_dotenv
from pyspark.sql import SparkSession

print("--- Iniciando ETL Bronze-para-Silver ---")
load_dotenv()
os.environ['HADOOP_HOME'] = 'C:\\hadoop'

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_URL = "jdbc:mysql://localhost:3306/nasa_cmaps"
DB_PROPERTIES = {
    "user": DB_USER,
    "password": DB_PASSWORD,
    "driver": "com.mysql.cj.jdbc.Driver"
}

BRONZE_TABLE = "bronze_fd00x"
SILVER_DIM_MOTOR = "dim_motor"
SILVER_DIM_CONFIG = "dim_configuracao"
SILVER_FACT_LEITURA = "fact_leitura_ciclo"

try:
    spark = SparkSession.builder \
        .appName("BronzeToSilver") \
        .config("spark.jars.packages", "mysql:mysql-connector-java:8.0.33") \
        .getOrCreate()

    print("SparkSession iniciada.")

    print(f"Lendo dados da tabela Bronze: {BRONZE_TABLE}...")
    bronze_df = spark.read.jdbc(
        url=DB_URL,
        table=BRONZE_TABLE,
        properties=DB_PROPERTIES
    )
    
    bronze_df.cache()
    print(f"Total de {bronze_df.count()} linhas lidas da Bronze.")
    
    print(f"Processando e carregando Dimensão: {SILVER_DIM_MOTOR}...")
    dim_motor_df = bronze_df.select("dataset_id", "unit_nr") \
                            .distinct() \
                            .withColumnRenamed("dataset_id", "fd_id") \
                            .withColumnRenamed("unit_nr", "motor_nr")
    
    dim_motor_df.write.mode("append").jdbc(
        url=DB_URL, table=SILVER_DIM_MOTOR, properties=DB_PROPERTIES
    )
    print(f"Dimensão {SILVER_DIM_MOTOR} carregada.")

    print(f"Processando e carregando Dimensão: {SILVER_DIM_CONFIG}...")
    dim_configuracao_df = bronze_df.select("setting1", "setting2", "setting3") \
                                   .distinct()

    dim_configuracao_df.write.mode("append").jdbc(
        url=DB_URL, table=SILVER_DIM_CONFIG, properties=DB_PROPERTIES
    )
    print(f"Dimensão {SILVER_DIM_CONFIG} carregada.")

    print("Lendo dimensões de volta para obter as chaves...")
    dim_motor_com_keys_df = spark.read.jdbc(
        url=DB_URL, table=SILVER_DIM_MOTOR, properties=DB_PROPERTIES
    )
    dim_config_com_keys_df = spark.read.jdbc(
        url=DB_URL, table=SILVER_DIM_CONFIG, properties=DB_PROPERTIES
    )

    sensor_cols = [f'sensor{i}' for i in range(1, 22)]
    
    print("Executando Join com dim_motor...")
    fact_df = bronze_df.join(
        dim_motor_com_keys_df,
        (bronze_df.dataset_id == dim_motor_com_keys_df.fd_id) & \
        (bronze_df.unit_nr == dim_motor_com_keys_df.motor_nr)
    ).select(
        dim_motor_com_keys_df.unit_id.alias("unit_id_fk"),
        "cycle", "setting1", "setting2", "setting3", *sensor_cols
    )

    print("Executando Join com dim_configuracao...")
    fact_df = fact_df.join(
        dim_config_com_keys_df,
        (fact_df.setting1 == dim_config_com_keys_df.setting1) & \
        (fact_df.setting2 == dim_config_com_keys_df.setting2) & \
        (fact_df.setting3 == dim_config_com_keys_df.setting3)
    ).select(
        "unit_id_fk",
        "cycle",
        dim_config_com_keys_df.setting_id.alias("setting_id_fk"),
        *sensor_cols
    )

    print(f"Carregando Tabela Fato: {SILVER_FACT_LEITURA}...")
    
    fact_df.repartition(4).write.mode("append").jdbc(
        url=DB_URL, table=SILVER_FACT_LEITURA, properties=DB_PROPERTIES
    )

    print("\n--- SUCESSO! ETL Bronze-para-Silver concluído. ---")

except Exception as e:
    print(f"\nOcorreu um erro fatal durante o ETL: {e}")

finally:
    if 'spark' in locals():
        spark.stop()
        print("SparkSession finalizada.")