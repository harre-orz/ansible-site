#!/bin/sh

set -u
set -e
set -x

BASE_URL="https://github.com/aelsabbahy/goss/releases/download"
CURL=/usr/sbin/curl
CURL_OPTS=-Lsf

cd $(dirname $0)

# amd64
for TAG in v0.3.0 v0.3.1 v0.3.2 v0.3.3 v0.3.4 v0.3.5 v0.3.6 v0.3.7; do
    [ ! -f "goss-linux-amd64_$TAG" ] && $CURL $CURL_OPTS "$BASE_URL/$TAG/goss-linux-amd64" > "goss-linux-amd64_$TAG"
done

# 386
for TAG in v0.3.0 v0.3.1 v0.3.2 v0.3.3 v0.3.4 v0.3.5 v0.3.6 v0.3.7; do
    [ ! -f "goss-linux-386_$TAG" ] && $CURL $CURL_OPTS "$BASE_URL/$TAG/goss-linux-386" > "goss-linux-386_$TAG"
done

# arm
for TAG in v0.3.5 v0.3.6 v0.3.7; do
    [ ! -f "goss-linux-arm_$TAG" ] && $CURL $CURL_OPTS "$BASE_URL/$TAG/goss-linux-arm" > "goss-linux-arm_$TAG"
done

# goss.py
[ ! -f "goss.py" ] && $CURL $CURL_OPTS https://raw.githubusercontent.com/indusbox/goss-ansible/1.0.0/goss.py > goss.py

echo "Success"
