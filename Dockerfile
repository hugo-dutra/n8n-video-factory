FROM n8nio/n8n:latest

USER root

# Instala ffmpeg + yt-dlp + utilitário dos2unix
RUN apk update \
 && apk add --no-cache ffmpeg yt-dlp dos2unix \
 && rm -rf /var/cache/apk/*

# Copia entrypoint e normaliza para LF
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh \
 && chown node:node /docker-entrypoint.sh

# Diretório de trabalho
WORKDIR /home/node

ENV SHELL=/bin/sh

USER node
EXPOSE 5678
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
