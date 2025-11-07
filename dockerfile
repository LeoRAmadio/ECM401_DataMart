# Usa uma imagem base que contenha Java (necessário para o Spark) e Python
FROM eclipse-temurin:17-jre-jammy

# Instala o Python e o pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean

# Cria um diretório de trabalho
WORKDIR /app

# Copia o arquivo de dependências
COPY requirements.txt .

# Instala as dependências
RUN pip3 install --no-cache-dir -r requirements.txt

# Comando para iniciar o script
CMD ["./run.sh"]