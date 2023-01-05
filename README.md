# MongoDB in a container

A containerised MongoDB server.

## Build

_Please note that because of the changes to [Docker Automated Builds](https://docs.docker.com/docker-hub/builds/)
many Docker images are now outdated and a manual build is required and recommended._

`podman build --no-cache -t konstruktoid/mongodb -f Dockerfile .`

### Environmental variables

```sh
ENV MONGOVER 5.0
ENV MONGOUSER mongodb
```

## Connecting

### Unencrypted

```sh
$ podman run --name mongo01 --cap-drop=all --cap-add={audit_write,setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb
$ podman exec -ti mongo01 mongosh --port 27017 --eval "printjson(db.hostInfo())"
Current Mongosh Log ID: 63b6a7e69af0388c5f754e94
Connecting to:    mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.6.1
Using MongoDB:    6.0.3
Using Mongosh:    1.6.1
```

### Using TLS/SSL

```sh
$ podman run --name mongo02 --cap-drop=all --cap-add={audit_write,setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
$ podman exec -ti mongo02 mongosh --tls --tlsAllowInvalidCertificates --port 27017 --eval 'printjson(db.hostInfo())'
Current Mongosh Log ID: 63b6a86f9dcca028f97c7626
Connecting to:    mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&tls=true&tlsAllowInvalidCertificates=true&appName=mongosh+1.6.1
Using MongoDB:    6.0.3
Using Mongosh:    1.6.1
```

## docker-compose

```sh
docker-compose up -d --build --remove-orphans
docker-compose scale mongo=3
docker inspect --format '{{ .NetworkSettings.Networks.mongodb_build_default.IPAddress }}' $(docker ps -q)
docker exec -ti mongodb_build_mongo_1 /bin/bash
```
