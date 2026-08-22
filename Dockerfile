FROM ubuntu:noble@sha256:d78ab76437b1afc5f01e223d6bf0172763f404bb166441328845adbef44518cb

LABEL org.opencontainers.image.title="mongodb" \
      org.opencontainers.image.description="Containerised MongoDB 8.0 server" \
      org.opencontainers.image.authors="Thomas Sjögren <konstruktoid@users.noreply.github.com>" \
      org.opencontainers.image.source="https://github.com/konstruktoid/container-mongodb-build" \
      org.opencontainers.image.url="https://www.mongodb.com/" \
      org.opencontainers.image.base.name="docker.io/library/ubuntu:noble"

ARG DEBIAN_FRONTEND=noninteractive
ENV MONGOVER=8.0
ENV MONGOUSER=mongodb

COPY ./files/ /etc/mongod/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# The archive key goes to its own keyring bound to the source with signed-by;
# /etc/apt/trusted.gpg.d grants the key authority over every configured
# repository, which this one does not need.
RUN groupadd -r "${MONGOUSER}" && \
    useradd -r -g "${MONGOUSER}" -d /data/db -s /usr/sbin/nologin "${MONGOUSER}" && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends ca-certificates curl gnupg openssl && \
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGOVER}.asc" | \
      gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${MONGOVER}.gpg" && \
    echo "deb [signed-by=/usr/share/keyrings/mongodb-server-${MONGOVER}.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/${MONGOVER} multiverse" \
      > "/etc/apt/sources.list.d/mongodb-org-${MONGOVER}.list" && \
    apt-get update && \
    apt-get -y install --no-install-recommends mongodb-org && \
    apt-get -y purge curl gnupg && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo && \
    mkdir -p /data/db && \
    chmod 0755 /etc/mongod/*.sh && \
    /etc/mongod/mongokeyfile.sh && \
    /etc/mongod/mongocert.sh && \
    chown -R "${MONGOUSER}:${MONGOUSER}" /data/db /etc/mongod /etc/ssl/mongodb.pem && \
    chmod 0400 /etc/mongod/mongodb.keyfile /etc/ssl/mongodb.pem

VOLUME ["/data/db"]
EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD ["mongosh", "--quiet", "--port", "27017", "--eval", "db.adminCommand('ping').ok"]

USER $MONGOUSER

ENTRYPOINT ["/etc/mongod/mongostart.sh"]
CMD []
