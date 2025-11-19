import pandas as pd
import glob
import os
import re
import warnings
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

warnings.filterwarnings("ignore")

col_names = ['unit_nr', 'cycle', 'setting1', 'setting2', 'setting3'] + [f'sensor{i}' for i in range(1, 22)]
repo_root = Path(__file__).resolve().parents[2]
data_dir = str(repo_root / 'data' / 'bronze')
file_pattern = os.path.join(data_dir, '*.txt')

try:
    file_paths = glob.glob(file_pattern)
    if not file_paths:
        raise FileNotFoundError(f"Nenhum arquivo .txt foi encontrado em {data_dir}")

    dfs_list = []
    print(f"Encontrados {len(file_paths)} arquivos. Carregando...")

    for file in file_paths:
        file_name = os.path.basename(file)
        match = re.search(r'FD00(\d)', file_name)

        if match:
            file_id = int(match.group(1))
        else:
            if 'train' not in file_name and 'test' not in file_name:
                continue
            file_id = 0

        temp_df = pd.read_csv(
            file,
            sep='\s+',
            header=None,
            names=col_names,
            engine='python'
        )

        temp_df['dataset_id'] = file_id
        dfs_list.append(temp_df)

    df_final_pandas = pd.concat(dfs_list, ignore_index=True)
    print("Pandas concluiu a leitura e combinação dos arquivos.")
    print(f"Total de linhas no Pandas: {len(df_final_pandas)}")

except Exception as e:
    print(f"\nOcorreu um erro durante a etapa do Pandas: {e}")
    exit()

print("\n--- Etapa 2: Iniciando Spark e convertendo DataFrame ---")

from pyspark.sql import SparkSession

try:
    spark = SparkSession.builder \
        .appName("PandasToMySQL") \
        .config("spark.jars.packages", "mysql:mysql-connector-java:8.0.33") \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("ERROR")

    spark_df = spark.createDataFrame(df_final_pandas)

    print("DataFrame Pandas convertido para DataFrame Spark com sucesso!")

    print("\n--- Etapa 3: Gravando dados no MySQL ---")

    db_host = os.getenv("DB_HOST", "localhost")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    db_database = "nasa_cmaps"
    mysql_table = "bronze_fd00x"

    if not db_user or not db_password:
        raise ValueError("Variáveis de ambiente DB_USER ou DB_PASSWORD não encontradas.")

    mysql_url = f"jdbc:mysql://{db_host}:3306/{db_database}"
    mysql_properties = {
        "user": db_user,
        "password": db_password,
        "driver": "com.mysql.cj.jdbc.Driver"
    }

    print(f"Iniciando gravação no MySQL (tabela: {mysql_table})...")

    spark_df.write \
        .mode("overwrite") \
        .jdbc(url=mysql_url, table=mysql_table, properties=mysql_properties)

    print("\n--- SCRIPT CONCLUÍDO ---")
    print(f"Dados gravados com sucesso no MySQL!")

except Exception as e:
    print(f"\nOcorreu um erro durante a etapa do Spark/MySQL: {e}")
