FROM konstruktoid/ubuntu:focal

COPY ./files/ /etc/mongod/

ENV MONGOVER 5.0
ENV MONGOUSER mongodb

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN groupadd -r "${MONGOUSER}" && \
    useradd -r -g "${MONGOUSER}" "${MONGOUSER}" && \
    ln -s /bin/true /bin/systemctl && \
    apt-get -y install ca-certificates curl gnupg --no-install-recommends && \
    curl -sSL "https://www.mongodb.org/static/pgp/server-${MONGOVER}.asc" | tee "/etc/apt/trusted.gpg.d/server-${MONGOVER}.asc" && \
    echo "deb https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${MONGOVER} multiverse" | \
      tee "/etc/apt/sources.list.d/mongodb-org-${MONGOVER}.list" && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y mongodb-org --no-install-recommends && \
    apt-get -y purge curl && \
    apt-get -y clean && \
    rm -rf "/var/lib/apt/lists/*" \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo && \
    mkdir -p /data/db && \
    chown -R "${MONGOUSER}:${MONGOUSER}" /data/db /etc/mongod && \
    chmod a+x /etc/mongod/*.sh && \
    chmod 400 /etc/mongod/mongodb.keyfile && \
    /etc/mongod/mongocert.sh

VOLUME /data/db
EXPOSE 27017

ENTRYPOINT ["/etc/mongod/mongostart.sh"]
CMD [""]
