FROM konstruktoid/debian:buster

COPY ./files/ /etc/mongod/

ENV GPGKEY 58712A2291FA4AD5 656408E390CFB1F5 4B7C549A058F8B6B 68818C72E52529D4
ENV MONGOVER development
ENV MONGOUSER mongodb

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN groupadd -r "${MONGOUSER}" && \
    useradd -r -g "${MONGOUSER}" "${MONGOUSER}" && \
    apt-get -y install gnupg --no-install-recommends && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ${GPGKEY} && \
    echo "deb http://repo.mongodb.org/apt/debian $(. /etc/os-release && \
    echo ${VERSION} | sed 's/[^a-z]*//g')/mongodb-org/${MONGOVER} main" | \
      tee "/etc/apt/sources.list.d/mongodb-org-${MONGOVER}.list" && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y mongodb-org ca-certificates --no-install-recommends && \
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
