
*Dockerized MongoDB 3.X with WiredTiger*     
A Docker MongoDB server.     
    
Automatic build details at https://registry.hub.docker.com/u/konstruktoid/mongodb/    

```sh
$ docker run --cap-drop=all --cap-add={setgid,setuid} -p 27017:27017 -d konstruktoid/mongodb  
$ mongo --port 27017 --eval "printjson(db.hostInfo())"   
```   
The previous Dockerfile and information is available in branch `replicaset`.  
