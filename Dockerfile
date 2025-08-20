FROM n8nio/n8n:latest

USER root

RUN apk update && apk add --no-cache ffmpeg youtube-dl && rm -rf /var/cache/apk/*

WORKDIR /home/node
COPY docker-entrypoint.sh /
ENV SHELL /bin/sh
USER node
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
EXPOSE 5678