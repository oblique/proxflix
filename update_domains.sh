#!/bin/sh

curl https://raw.githubusercontent.com/ab77/netflix-proxy/master/data/conf/zones.override.template | \
    awk '/^zone\s/ { if (match($2, /^"(.+)\."$/, m) != 0) print m[1]; }' > domains
