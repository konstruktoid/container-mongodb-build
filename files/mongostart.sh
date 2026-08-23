#!/bin/sh
# Entry point for the MongoDB container.
#
# The image already runs as the mongodb user, so no privilege drop is needed
# here. exec keeps mongod as PID 1 so it receives the signals sent on stop,
# and "$@" forwards arguments without the word splitting that reusing $* in a
# shell -c string would introduce.
#
# The keyfile and TLS certificate are generated here rather than at build
# time so they never end up in an image layer; /run/mongod-secrets is a
# tmpfs, so they also never touch disk. Skip generation when a file is
# already present, which lets a bind mount override it (e.g. a shared
# replica-set keyfile).

set -eu

mkdir -p /run/mongod-secrets

[ -f /run/mongod-secrets/mongodb.keyfile ] || /etc/mongod/mongokeyfile.sh
[ -f /run/mongod-secrets/mongodb.pem ] || /etc/mongod/mongocert.sh

exec /usr/bin/mongod --config /etc/mongod/mongodb.conf --bind_ip_all "$@"
