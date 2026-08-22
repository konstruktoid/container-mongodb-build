#!/bin/sh
# Entry point for the MongoDB container.
#
# The image already runs as the mongodb user, so no privilege drop is needed
# here. exec keeps mongod as PID 1 so it receives the signals sent on stop,
# and "$@" forwards arguments without the word splitting that reusing $* in a
# shell -c string would introduce.

set -eu

exec /usr/bin/mongod --config /etc/mongod/mongodb.conf --bind_ip_all "$@"
