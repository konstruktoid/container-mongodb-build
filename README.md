
*Dockerized MongoDB 3.X with WiredTiger*  
A Docker MongoDB server.  

Automatic build details at https://registry.hub.docker.com/u/konstruktoid/mongodb/  

```sh
$ docker run --cap-drop=all --cap-add={setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb
$ mongo --port 27017 --eval "printjson(db.hostInfo())"  
```

TLS/SSL Configuration:  

```sh
$ docker run --cap-drop=all --cap-add={setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
$ mongo --ssl --sslAllowInvalidCertificates --port 27017 --eval 'printjson(db.hostInfo())'
```

```sh
$ docker-compose up -d --build --remove-orphans
$ docker-compose scale mongo=3
$ docker inspect --format '{{ .NetworkSettings.Networks.mongodbbuild_default.IPAddress }}' $(docker ps -qa)
$ docker exec -ti ba61262f52f1 /bin/bash
```

The previous replica set Dockerfile and information is available in branch `replicaset`, but that is very old code.
