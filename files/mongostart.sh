#!/bin/bash
conf='/etc/mongod/mongodb.conf'
args="$*"

su - mongodb -c "/usr/bin/mongod --config ${conf} --bind_ip_all ${args}"
