#!/bin/sh
# Generate the shared cluster authentication keyfile.
#
# The keyfile is a shared secret: every member of a replica set authenticates
# with it, so it is generated per build and never committed to the repository.
# Replica set members that must talk to each other need the *same* key, so for
# anything beyond a single-node lab mount a keyfile of your own over
# /etc/mongod/mongodb.keyfile instead of relying on the generated one.

set -eu

keyfile='/etc/mongod/mongodb.keyfile'

openssl rand -base64 756 > "${keyfile}"
chmod 0400 "${keyfile}"
