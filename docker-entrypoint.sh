#!/bin/sh
set -e

# Trust custom certificates, se existirem
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
  export SSL_CERT_DIR=/opt/custom-certificates
  c_rehash /opt/custom-certificates
fi

# Importa workflows, se existir diretório
if [ -d /home/n8n_workflow ]; then
  /usr/local/bin/n8n import:workflow --separate --input=/home/n8n_workflow || true
fi


# Sobe o n8n
if [ "$#" -gt 0 ]; then
  exec n8n "$@"
else
  exec n8n
fi