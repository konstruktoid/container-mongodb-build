FROM debian:wheezy

COPY ./files/ /etc/mongod/

RUN \
    groupadd -r mongodb && \
    useradd -r -g mongodb mongodb

RUN \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo "deb http://repo.mongodb.org/apt/debian "$(. /etc/os-release && echo $VERSION | sed 's/[^a-z]*//g')"/mongodb-org/3.0 main" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y sudo mongodb-org ca-certificates --no-install-recommends && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo

RUN \
    mkdir -p /data/db && \
    chown -R mongodb:mongodb /data/db /etc/mongod && \
    chmod a+x /etc/mongod/mongostart.sh

VOLUME /data/db
EXPOSE 27017

ENTRYPOINT ["/etc/mongod/mongostart.sh"]
CMD []
