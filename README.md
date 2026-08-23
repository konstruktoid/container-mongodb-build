# MongoDB in a container

A containerised MongoDB 8.0 server built on `ubuntu:noble`.

## Build

_Please note that because of the changes to
[Docker Automated Builds](https://docs.docker.com/docker-hub/builds/) many Docker
images are now outdated and a manual build is required and recommended._

```sh
podman build --no-cache -t konstruktoid/mongodb -f Dockerfile .
```

### Environment variables

```sh
ENV MONGOVER=8.0
ENV MONGOUSER=mongodb
```

### Cluster authentication keyfile

`files/mongokeyfile.sh` generates `/run/mongod-secrets/mongodb.keyfile` when the
container starts, not during the build, so the key never ends up in an image
layer. It is a shared secret, so it is never committed to this repository and
every container start produces a different one.

Members of the same replica set must share one key, so for anything beyond a
single-node lab, mount your own keyfile over the generated one. It has to be
mode `0400` and owned by the `mongodb` user:

```sh
openssl rand -base64 756 > mongodb.keyfile
chmod 0400 mongodb.keyfile
podman run -v ./mongodb.keyfile:/run/mongod-secrets/mongodb.keyfile:ro,Z ... konstruktoid/mongodb
```

## Running

The image runs as the unprivileged `mongodb` user and needs no added
capabilities. `mongod` runs as PID 1, so it receives the signals sent on stop.

### Unencrypted

```sh
$ podman run --name mongo01 --cap-drop=all -p 27017:27017 -d konstruktoid/mongodb
$ podman exec -ti mongo01 mongosh --port 27017 --eval "printjson(db.hostInfo())"
```

### Using TLS

A self-signed certificate is generated when the container starts: the key and
certificate together at `/run/mongod-secrets/mongodb.pem`, and the certificate
alone at `/run/mongod-secrets/mongodb-cert.crt`. The CN is the container's
hostname, with `localhost` and `127.0.0.1` as subject alternative names. It is
fine for a lab and nothing else.

```sh
$ podman run --name mongo02 --cap-drop=all -p 27017:27017 -d konstruktoid/mongodb \
    --tlsMode requireTLS --tlsCertificateKeyFile /run/mongod-secrets/mongodb.pem \
    --tlsCAFile /run/mongod-secrets/mongodb-cert.crt --tlsAllowConnectionsWithoutCertificates
$ podman exec -ti mongo02 mongosh --tls --tlsAllowInvalidCertificates --port 27017 \
    --eval 'printjson(db.hostInfo())'
```

Both extra flags are required on MongoDB 8.0:

* Without `--tlsCAFile`, `mongod` refuses to start at all — _"The use of TLS
  without specifying a chain of trust is no longer supported"_
  ([SERVER-72839](https://jira.mongodb.org/browse/SERVER-72839)). The
  self-signed certificate is its own trust chain, so it doubles as the CA file.
* Naming a CA file makes `mongod` demand a client certificate in turn, so
  `--tlsAllowConnectionsWithoutCertificates` is what lets the `mongosh` line
  above connect.

`mongod` 8.0 accepts only the `--tls*` spellings; the older `--sslMode` and
`--sslPEMKeyFile` are gone.

> [!NOTE]
> The `HEALTHCHECK` connects without `--tls`, so a container started in
> `requireTLS` mode never reports `healthy`. The server is fine; the probe
> cannot reach it. Override it with `--health-cmd` if you need the status to be
> meaningful in that mode.

## Configuration

`files/mongodb.conf` sets `dbPath` to `/data/db`, uses the WiredTiger engine, and
logs to stdout rather than a file so the container runtime collects the output
and the image needs no writable log directory.

Under `security` it enables `authorization`, sets `clusterAuthMode: keyFile`, and
leaves `transitionToAuth: true` — which means **unauthenticated connections are
still accepted**. That is what lets the single-node lab image start without any
user being created. Set it to `false` once you have created an admin user.

`replSetName` is `docker`, but the set is not initiated for you:

```sh
podman exec -ti mongo01 mongosh --port 27017 --eval 'rs.initiate()'
```

The [`replicaset` branch](https://github.com/konstruktoid/container-mongodb-build/tree/replicaset)
carries a multi-node variant.

## Health check

The `HEALTHCHECK` runs `db.adminCommand("ping")` through `mongosh`.

## Compose

`docker-compose.yml` runs the container read-only with all capabilities dropped
and `no-new-privileges`, keeping the data in a named volume:

```sh
docker compose up -d --build --remove-orphans
docker compose ps
docker compose exec mongo mongosh --port 27017
```

## Development

`.pre-commit-config.yaml` runs gitleaks, hadolint, shellcheck, actionlint
and markdownlint:

```sh
pre-commit run --all-files
```
