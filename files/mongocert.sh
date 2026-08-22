#!/bin/sh
# Generate a self-signed certificate for TLS.
#
# ONLY FOR TESTING - a self-signed certificate is not a substitute for one
# issued by a CA the clients trust.
# https://www.mongodb.com/docs/manual/tutorial/configure-ssl/

set -eu

cn="$(hostname -f 2>/dev/null || hostname)"

openssl req -newkey rsa:4096 -new -x509 -days 365 -nodes \
  -subj "/CN=${cn}" \
  -addext "subjectAltName=DNS:${cn},DNS:localhost,IP:127.0.0.1" \
  -out /etc/ssl/mongodb-cert.crt \
  -keyout /etc/ssl/mongodb-cert.key

cat /etc/ssl/mongodb-cert.key /etc/ssl/mongodb-cert.crt > /etc/ssl/mongodb.pem
rm -f /etc/ssl/mongodb-cert.key
chmod 0400 /etc/ssl/mongodb.pem
# The certificate on its own is the CA file mongod needs; world readable so it
# can also be copied out for clients.
chmod 0644 /etc/ssl/mongodb-cert.crt

# MongoDB 8.0 will not start with TLS unless a chain of trust is named, and
# naming one makes it require client certificates in turn, hence both extra
# flags below. The self-signed certificate acts as its own CA.
#
# podman run --cap-drop=all -p 27017:27017 -d konstruktoid/mongodb \
#   --tlsMode requireTLS --tlsCertificateKeyFile /etc/ssl/mongodb.pem \
#   --tlsCAFile /etc/ssl/mongodb-cert.crt --tlsAllowConnectionsWithoutCertificates
# mongosh --tls --tlsAllowInvalidCertificates --port 27017 --eval 'db.hostInfo()'
