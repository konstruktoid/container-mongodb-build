#!/bin/bash
conf='/etc/mongod/mongodb.conf'
args="$@"

sudo -u mongodb /usr/bin/mongod --config $conf $args
