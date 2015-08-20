#!/bin/sh
# ONLY FOR TESTING
# http://docs.mongodb.org/manual/tutorial/configure-ssl/

cd /etc/ssl/
openssl req -newkey rsa:4096 -new -x509 -days 365 -subj "/CN=$(hostname --long)" -nodes -out mongodb-cert.crt -keyout mongodb-cert.key
cat mongodb-cert.key mongodb-cert.crt > mongodb.pem

# docker run --cap-drop=all --cap-add={setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
# mongo --ssl --port 27017 --eval "printjson(db.hostInfo())"
