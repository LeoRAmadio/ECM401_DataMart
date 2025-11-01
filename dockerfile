# Use uma imagem base que contenha Java (necessário para o Spark) e Python
FROM eclipse-temurin:17-jre-jammy

# Instale o Python e o pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean

# Crie um diretório de trabalho
WORKDIR /app

# Copie o arquivo de dependências e instale-as
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copie os diretórios do seu projeto para dentro do contêiner
COPY BRONZE/ ./BRONZE/
COPY SILVER/ ./SILVER/

# Copie o script de execução (que criaremos a seguir)
COPY run.sh .
RUN chmod +x run.sh

# Comando para iniciar o script
CMD ["./run.sh"]