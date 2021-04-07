# OpenSSL node configuration file
[ req ]
prompt=no
distinguished_name = distinguished_name
req_extensions = extensions

[ distinguished_name ]
organizationName = Cockroach

[ extensions ]
subjectAltName = critical,DNS:localhost,IP:127.0.0.1,IP:$INTERNAL_IP,IP:$EXTERNAL_IP
