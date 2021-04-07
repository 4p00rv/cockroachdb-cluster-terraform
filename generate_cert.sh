#!/bin/bash -xe

NODE_CRT_PWD=${NODE_CRT_PWD:-test123}
envsubst < conf/node.conf.tpl > /tmp/node.conf
mkdir -p certs
openssl genrsa -out certs/node.key 2048
chmod 400 certs/node.key
openssl req -new -config /tmp/node.conf -out /tmp/node.csr \
  -passout pass:$NODE_CRT_PWD -batch
openssl ca -config conf/ca.conf -keyfile safe-dir/ca.key \
  -cert certs/ca.crt -policy signing_policy -extensions signing_node_req \
  -out certs/node.crt -outdir certs/ -in /tmp/node.csr -batch 
