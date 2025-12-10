# --- Stage 1: pegar o binário do Deno (para futura resolução n/sig) ---
FROM denoland/deno:bin AS denobin

# --- Stage 2: imagem final n8n com yt-dlp e configs ---
FROM n8nio/n8n:1.120.4

USER root

# Para alternar a origem do yt-dlp: nightly (recomendado hoje) ou stable
ARG YTDLP_CHANNEL=nightly
# Opcional: use para "estourar" o cache quando quiser
ARG CACHE_BUSTER=now

# Pacotes úteis + yt-dlp (baixado por curl) + Deno (copiado do stage 1)
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
      curl -L https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/latest/download/yt-dlp \
        -o /usr/local/bin/yt-dlp; \
    else \
      curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
        -o /usr/local/bin/yt-dlp; \
    fi; \
    chmod a+rx /usr/local/bin/yt-dlp

# Copia o binário do Deno para a imagem final (fica no PATH)
COPY --from=denobin /deno /usr/local/bin/deno

# Defaults do yt-dlp para mitigar 403 agora e já preparar o ambiente
# - força IPv4 (muitas rotas IPv6 dão 403)
# - usa player_js_version=actual (dribla player "pinned" quebrado)
# - tenta BV+BA; se falhar, cai para progressivo MP4; por fim, best
RUN mkdir -p /home/node/cookies \
 && printf '%s\n' \
  '--force-ipv4' \
  '--extractor-args youtube:player_js_version=actual' \
  '-f bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/best' \
  '--merge-output-format mp4' \
  '--retries 10' \
  '--fragment-retries 10' \
  '--sleep-interval 1' \
  '--max-sleep-interval 2.5' \
  > /etc/yt-dlp.conf \
 && chown -R node:node /home/node \
 && chmod 644 /etc/yt-dlp.conf

# (Opcional) Se você tiver um entrypoint customizado, copie aqui
# COPY docker-entrypoint.sh /docker-entrypoint.sh
# RUN dos2unix /docker-entrypoint.sh || true \
#  && chmod +x /docker-entrypoint.sh \
#  && chown node:node /docker-entrypoint.sh

WORKDIR /home/node
ENV SHELL=/bin/sh

USER node
EXPOSE 5678

# Se você usa o entrypoint padrão do n8n, mantenha:
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
