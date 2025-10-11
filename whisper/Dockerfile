FROM python:3.10-slim

# Instala dependências do sistema
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências do Whisper e FastAPI
RUN pip install --default-timeout=100 --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir openai-whisper fastapi uvicorn python-multipart

# Define o cache do Whisper para um diretório persistente
ENV XDG_CACHE_HOME=/root/.cache

# Baixa o modelo Whisper durante a build para evitar downloads na execução
RUN python -c "import whisper; whisper.load_model('large')"

# Copia os arquivos do projeto
COPY . .

# Expor a porta da API
EXPOSE 8000

# Comando padrão para rodar a API
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
