#!/bin/bash -xe

INDEX=${INDEX:-0}
sleep `expr 5 + 2 \* ${INDEX}`

envsubst < conf/node.conf.tpl > /tmp/node${INDEX}.conf

if [ ! -f "safe-dir/ca.key" ]; then
  echo "Please generate the ca key and place it under $PWD/safe-dir/ca.key"
  exit
fi

mkdir -p certs
openssl genrsa -out certs/node${INDEX}.key 2048
chmod 400 certs/node${INDEX}.key
openssl req -new -config /tmp/node${INDEX}.conf -out /tmp/node${INDEX}.csr \
  -key certs/node${INDEX}.key -batch
openssl ca -config conf/ca.conf -keyfile safe-dir/ca.key \
  -cert certs/ca.crt -policy signing_policy -extensions signing_node_req \
  -out certs/node${INDEX}.crt -outdir certs/ -in /tmp/node${INDEX}.csr -batch 

# rm generated pem files
rm /tmp/node${INDEX}.csr /tmp/node${INDEX}.conf
rm certs/*.pem
