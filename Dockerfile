FROM n8nio/n8n:latest

USER root

# Use --build-arg YTDLP_CHANNEL=stable para fixar na versão estável, ou mantenha "nightly" (recomendado)
ARG YTDLP_CHANNEL=nightly

# Pacotes necessários + yt-dlp (nightly por padrão)
RUN apk add --no-cache \
      ffmpeg \
      imagemagick \
      fontconfig \
      font-dejavu \
      font-liberation \
      font-noto \
      python3 \
      curl \
      bash \
      ca-certificates \
      dos2unix \
      jq \
      file \
 && set -eux; \
    if [ "$YTDLP_CHANNEL" = "nightly" ]; then \
      curl -L https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp; \
    else \
      curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp; \
    fi; \
    chmod a+rx /usr/local/bin/yt-dlp \
 # Defaults do yt-dlp para reduzir 403 e evitar recode desnecessário
 && mkdir -p /home/node/cookies \
 && printf '%s\n' \
    '-4' \
    '--extractor-args youtube:player_client=default,-tv,web_embedded' \
    '-f bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]' \
    '--merge-output-format mp4' \
    '--retries 10' \
    '--fragment-retries 10' \
    '--sleep-interval 1.0' \
    '--max-sleep-interval 2.5' \
    > /etc/yt-dlp.conf \
 && chown -R node:node /home/node /etc/yt-dlp.conf

# Seu entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh || true \
  && chmod +x /docker-entrypoint.sh \
  && chown node:node /docker-entrypoint.sh

WORKDIR /home/node
ENV SHELL=/bin/sh

USER node
EXPOSE 5678
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
