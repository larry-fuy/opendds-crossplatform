#!/bin/sh
docker run \
-d --name update -v "$PWD/scripts:/scripts" -w /scripts
yongfu/opendds \
/scripts/update_linux.sh
wait
docker commit update opendds
