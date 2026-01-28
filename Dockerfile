# --- Stage 1: pegar o binário do Deno ---
FROM denoland/deno:bin AS denobin

# --- Stage 2: imagem final n8n com yt-dlp e configs ---
FROM n8nio/n8n:1.120.4

USER root

# Dependências (tudo em um RUN só, sem duplicar)
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
    python3 \
    py3-matplotlib \
    py3-numpy \
    py3-pillow \
    nodejs \
    npm \
  && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
       -o /usr/local/bin/yt-dlp \
  && chmod a+rx /usr/local/bin/yt-dlp

# (Opcional, mas recomendado já que você tem o stage)
COPY --from=denobin /deno /usr/local/bin/deno
RUN chmod a+rx /usr/local/bin/deno

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh || true \
  && chmod +x /docker-entrypoint.sh \
  && chown node:node /docker-entrypoint.sh

WORKDIR /home/node
ENV SHELL=/bin/sh

USER node
EXPOSE 5678

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
