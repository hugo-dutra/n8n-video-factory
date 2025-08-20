#!/bin/sh
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
  export SSL_CERT_DIR=/opt/custom-certificates
  c_rehash /opt/custom-certificates
fi
/usr/local/bin/n8n import:workflow --separate --input=/home/n8n_workflow

mkdir ~/.n8n/nodes
cd ~/.n8n/nodes

#npm install n8n-nodes-oracle-database-parameterization
if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec n8n "$@"
else
  # Got started without arguments
  exec n8n
fi