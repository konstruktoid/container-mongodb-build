#!/bin/sh
# Generate the shared cluster authentication keyfile.
#
# The keyfile is a shared secret: every member of a replica set authenticates
# with it, so it is generated at container startup, lives only in the
# tmpfs-backed /run/mongod-secrets, and is never baked into an image layer.
# Replica set members that must talk to each other need the *same* key, so for
# anything beyond a single-node lab mount a keyfile of your own over
# /run/mongod-secrets/mongodb.keyfile instead of relying on the generated one.

set -eu

keyfile='/run/mongod-secrets/mongodb.keyfile'

openssl rand -base64 756 > "${keyfile}"
chmod 0400 "${keyfile}"
