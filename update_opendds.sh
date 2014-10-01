#!/bin/sh
# run a Docker container and update OpenDDS and then commit
# it as another image
docker run \
-d --name update -v "$PWD/scripts:/scripts" -w /scripts \
docker_opendds \
/scripts/update_linux.sh
pid=$(docker inspect --format '{{ .State.Pid }}' update) 

# wait the docker container finished
echo "updating OpenDDS code ..."
while [ -d  /proc/$pid ]; do
    sleep 1
done

docker rmi opendds_update
docker commit update opendds_update
docker rm update


