#!/bin/sh

# clean docker containers
# stop and clean 
echo "stop and clean docker containers..."
docker stop ${names[*]} > /dev/null 2>&1
docker rm ${names[*]} > /dev/null 2>&1

#stop vagrant box
echo "stop vagrant box..."
vgrant halt
