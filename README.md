# Dockerized MongoDB

A Docker MongoDB server.

## Build

`docker build --no-cache -t konstruktoid/mongodb -f Dockerfile .`

### Environmental variables

```sh
ENV MONGOVER 5.0
ENV MONGOUSER mongodb
```

## Connecting

```sh
docker run --cap-drop=all --cap-add={audit_write,setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb
mongo --port 27017 --eval "printjson(db.hostInfo())"
```

## TLS/SSL Configuration

```sh
docker run --cap-drop=all --cap-add={audit_write,setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
mongo --ssl --sslAllowInvalidCertificates --port 27017 --eval 'printjson(db.hostInfo())'
```

## docker-compose

```sh
docker-compose up -d --build --remove-orphans
docker-compose scale mongo=3
docker inspect --format '{{ .NetworkSettings.Networks.mongodb_build_default.IPAddress }}' $(docker ps -q)
docker exec -ti mongodb_build_mongo_1 /bin/bash
```

The previous replica set Dockerfile and information is available in branch `replicaset`, but that is very old code.
