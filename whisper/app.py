import whisper
from fastapi import FastAPI, UploadFile, File, Response
import shutil
import os
import logging

# Configuração de logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

app = FastAPI()

# Carregar o modelo Whisper Large
logging.info("Carregando modelo Whisper Large...")
model = whisper.load_model("large")
logging.info("Modelo carregado com sucesso.")


def convert_to_srt(segments):
    """ Converte os segmentos de transcrição para o formato SRT """
    srt_output = []
    for i, segment in enumerate(segments):
        start = segment["start"]
        end = segment["end"]
        text = segment["text"]

        # Formatar tempo no estilo SRT (hh:mm:ss,mmm)
        start_time = f"{int(start // 3600):02}:{int((start % 3600) // 60):02}:{int(start % 60):02},{int((start % 1) * 1000):03}"
        end_time = f"{int(end // 3600):02}:{int((end % 3600) // 60):02}:{int(end % 60):02},{int((end % 1) * 1000):03}"

        srt_output.append(f"{i + 1}\n{start_time} --> {end_time}\n{text}\n")

    return "\n".join(srt_output)


@app.post("/subtitle/")
async def transcribe_audio(file: UploadFile = File(...)):
    try:
        logging.info(f"Recebendo arquivo: {file.filename} (tipo: {file.content_type})")

        # Salvar o arquivo temporariamente
        file_path = f"temp_{file.filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        file_size = os.path.getsize(file_path)
        logging.info(f"Arquivo salvo temporariamente em {file_path} (tamanho: {file_size} bytes)")

        # Iniciar transcrição
        logging.info("Iniciando transcrição do áudio...")
        result = model.transcribe(file_path, language="portuguese")
        logging.info("Transcrição concluída com sucesso.")

        # Converter para formato SRT
        srt_content = convert_to_srt(result["segments"])

        # Remover o arquivo de áudio temporário
        os.remove(file_path)
        logging.info(f"Arquivo temporário {file_path} removido.")

        # Retornar o arquivo .srt como resposta
        logging.info(f"Retornando transcrição para {file.filename}.srt")
        return Response(content=srt_content, media_type="text/plain", headers={
            "Content-Disposition": f'attachment; filename="{file.filename}.srt"'
        })

    except Exception as e:
        logging.error(f"Erro ao processar arquivo {file.filename}: {e}", exc_info=True)
        return Response(content="Erro ao processar o arquivo.", status_code=500)

@app.post("/transcribe/")
async def simple_transcription(file: UploadFile = File(...)):
    try:
        logging.info(f"Recebendo arquivo: {file.filename} (tipo: {file.content_type})")

        # Salvar o arquivo temporariamente
        file_path = f"temp_{file.filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        logging.info(f"Arquivo salvo temporariamente em {file_path}")

        # Iniciar transcrição
        logging.info("Iniciando transcrição simples do áudio...")
        result = model.transcribe(file_path, language="portuguese")
        logging.info("Transcrição concluída com sucesso.")

        # Remover o arquivo de áudio temporário
        os.remove(file_path)
        logging.info(f"Arquivo temporário {file_path} removido.")

        # Retornar apenas o texto transcrito sem marcadores
        return result["text"]

    except Exception as e:
        logging.error(f"Erro ao processar arquivo {file.filename}: {e}", exc_info=True)
        return Response(content="Erro ao processar o arquivo.", status_code=500)

@app.post("/transcribe-word-timestamps/")
async def transcribe_with_timestamps(file: UploadFile = File(...)):
    try:
        logging.info(f"Recebendo arquivo: {file.filename} (tipo: {file.content_type})")
        
        file_path = f"temp_{file.filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        logging.info(f"Arquivo salvo temporariamente em {file_path}")
        result = model.transcribe(file_path, language="portuguese", word_timestamps=True)
        logging.info("Transcrição concluída com sucesso.")

        os.remove(file_path)
        logging.info(f"Arquivo temporário {file_path} removido.")
        
        # Retornar JSON com os timestamps por palavra
        words_with_timestamps = []
        for segment in result["segments"]:
            for word in segment["words"]:
                words_with_timestamps.append({
                    "word": word.get("word", word.get("text", "")),
                    "start": word["start"],
                    "end": word["end"]
                })

        return {"transcription": words_with_timestamps}
    except Exception as e:
        logging.error(f"Erro ao processar arquivo {file.filename}: {e}", exc_info=True)
        return Response(content="Erro ao processar o arquivo.", status_code=500)