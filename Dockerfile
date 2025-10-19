FROM n8nio/n8n:latest

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
    dos2unix \
    jq \
    file

# Pacotes essenciais
RUN apk add --no-cache ffmpeg python3 curl bash ca-certificates dos2unix \
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
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
