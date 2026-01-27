# --- Stage 1: pegar o binário do Deno (para futura resolução n/sig) ---
FROM denoland/deno:bin AS denobin

# --- Stage 2: imagem final n8n com yt-dlp e configs ---
FROM n8nio/n8n:1.120.4

USER root


RUN apk add --no-cache \
    ffmpeg \
    imagemagick \
    fontconfig \
    font-dejavu \
    font-liberation \
    font-noto \
    curl \
    bash \
    ca-certificates \
    dos2unix

# Pacotes essenciais
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-matplotlib \
    py3-numpy \
    py3-pillow \
    curl \
    bash \
    ca-certificates \
    dos2unix \
  && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
       -o /usr/local/bin/yt-dlp \
  && chmod a+rx /usr/local/bin/yt-dlp


COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh || true \
  && chmod +x /docker-entrypoint.sh \
  && chown node:node /docker-entrypoint.sh

WORKDIR /home/node
ENV SHELL=/bin/sh

USER node
EXPOSE 5678

# Se você usa o entrypoint padrão do n8n, mantenha:
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
