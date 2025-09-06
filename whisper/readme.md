# Whisper API - Transcrição de Áudio para Legendas (.srt)

Este projeto fornece uma API baseada em **Whisper Large** para transcrição de áudios em **português**, retornando o resultado em **formato .srt**.

## 1. Requisitos
- **Docker** e **Docker Compose** instalados.

## 2. Subir a API
Para iniciar a API, basta executar:

```sh
docker-compose up --build -d
```

Isso irá:
✅ Construir a imagem do Whisper API  
✅ Subir o container da API  
✅ Manter o modelo em cache para evitar downloads repetidos  

Caso precise parar a API:
```sh
docker-compose down
```

## 3. Fazer uma Requisição no Postman
1. **Abra o Postman**
2. Escolha o método **POST**
3. No campo **URL**, insira:
   ```
   http://localhost:8000/transcribe/
   ```
4. No **Body**:
   - Selecione **form-data**
   - Adicione uma chave chamada `file`
   - No valor, selecione um arquivo `.mp3` ou `.wav`
5. Clique em **Send**

O retorno será um arquivo `.srt` com a transcrição do áudio.

---

## 4. Arquivos do Projeto

### `Dockerfile`
```dockerfile
FROM python:3.10-slim

# Instala dependências do sistema
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências do Whisper e FastAPI
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir openai-whisper fastapi uvicorn python-multipart

# Expõe a porta da API
EXPOSE 8000

# Comando para rodar o servidor
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### `docker-compose.yml`
```yaml
version: "3.8"

services:
  whisper-api:
    build: .
    container_name: whisper-api
    ports:
      - "8000:8000"
    volumes:
      - ~/.cache/whisper:/root/.cache/whisper  # Cache dos modelos para evitar downloads repetidos
    restart: unless-stopped
```

---

### `app.py`
```python
import whisper
from fastapi import FastAPI, UploadFile, File, Response
import shutil
import os

app = FastAPI()

# Carregar o modelo Whisper Large
model = whisper.load_model("large")

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    # Salvar o arquivo temporariamente
    file_path = f"temp_{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Transcrever áudio em português
    result = model.transcribe(file_path, language="portuguese")

    # Gerar o conteúdo do arquivo .srt
    srt_content = whisper.utils.write_srt(result["segments"])

    # Remover o arquivo de áudio temporário
    os.remove(file_path)

    # Retornar o arquivo .srt como resposta
    return Response(content=srt_content, media_type="text/plain", headers={
        "Content-Disposition": f'attachment; filename="{file.filename}.srt"'
    })
```

Agora a API está pronta para uso! 🚀