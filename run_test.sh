#!/bin/sh
docker_ver=1.1.2
vagrant_ver=1.6.3
vbox_ver=4.3.14
# kernel version is not a strict requirement 
#kernel_ver=3.15.10

OPTIONS=$(getopt -o hi:p: -- "$@")
eval set -- "$OPTIONS"

# echo "$OPTIONS"

while [ $# -gt 0 ]
do
    case "$1" in
     	  -h)
	    echo "Usage: run-test [OPTIONS] [-i repo_port] [-p host_port]"
	    echo "Run a distributed test (Mesenger) of OpenDDS";
	    echo "Options: ";
	    echo "    -h    Show this message"
	    echo "    -i     The port number used by Inforepo"
	    echo "    -p    The port number used by Publisher or Subscriber"
	    break ;;
    	 -i )
	    if ! [[ $2 =~ ^[0-9]+$ ]] ; then
		echo "$2 not a number for inforepo port"; exit 1
	    fi
	    repo_port=$2; shift 2 ;;
	-p ) 
	    if ! [[ $2 =~ ^[0-9]+$ ]] ; then
		echo "$2 not a number for inforepo port"; exit 1
	    fi	  
	    host_port=$2; shift 2 ;;
	--) shift ;;
	*) echo "Internal error!" ; exit 1 ;;
    esac
done

# check package and their version
./check

# rebuild Vagrant box if not found
rebuild_v=$(vagrant box list | grep '^dds')
if [ -z "$rebuild_v" ] ; then 
    echo "No existed Vagrant box..."
    ./rebuild docker
fi

# rebuild Docker image if not found
rebuild_d=$(docker images | grep docker_opendds)
if [ -z "$rebuild_d" ]; then
    echo "No existed Docker image..."
    ./rebuild vagrant
fi

# Let linux kernel forward the packet
echo "turn on Linux kernel forwarding packets..."
forward=$(cat /proc/sys/net/ipv4/ip_forward)
if [ $forward -eq 0 ]; then
    sudo 'echo 1 > /proc/sys/net/ipv4/ip_forward' 
fi

[ "$repo_port" ] ||  repo_port=15000
[ "$host_port" ] ||  host_port=1234 

echo "inforepo port...: $repo_port"
echo "host port...: $host_port"

# prepare to run inforepo
echo "prepare vagrant box..."
vm_name=repo_vm
sed -e "s/repo_port/$repo_port/g" \
-e "s/vm_name/$vm_name/g" \
Vagrant_template > Vagrantfile

echo "check virtual box bridge..."
eval "ip addr show vboxnet0 > /dev/null"
if [[ $? -ne 0 ]]; then
    vboxmanage hostonlyif create
fi

#repo_run=$(vagrant status | grep repo_vm | grep -q running)
if ! vagrant status | grep repo_vm | grep -q running ; then  
    echo "start virtual machine...";
    vagrant up --no-provision
else 
    echo "virtual machine is running..."
fi

echo "check network..."
vnet=$(vboxmanage showvminfo repo_vm | grep "NIC.*Host-only" | gawk '{print $8}' | sed -e "s/'//g" -e "s/,//g")
repo_gateway=$(ip addr show $vnet | grep -w inet | gawk '{print $2}' | sed 's/\/24//')
repo_ip=$(echo $repo_gateway | gawk -F. '{print $1"."$2"."$3"."$4+1}')
echo "inforepo ip...: $repo_ip"
echo "inforepo port...: $repo_port"

echo "start running inforepo..."
sed -e "s/repo_port/$repo_port/g" \
    -e "s/repo_ip/$repo_ip/g" \
    -e "s/repo_gateway/$repo_gateway/g" \
    ./scripts/run_dds_win_template.bat > ./scripts/run_dds_win.bat ;
vagrant provision &

# echo "wait a moment for inforepo starting..."
sleep 30

echo "check running containers..."
docker ps | grep pub
if [[  $? -ne 0 ]]; then
    echo "delete pub ... "
    docker stop pub
    docker rm  -f pub 
fi
docker ps | grep sub
if [[ $? -ne 0 ]]; then
    echo "delete pub ... "
    docker stop sub
    docker rm  -f sub
fi

# update OpenDDS source code
echo "update OpenDDS on Docker image..."
update_opendds.sh

echo "run publisher..."
docker run \
-d --name pub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
--env "repo_ip=$repo_ip"  --env "host_port=$host_port" \
-p $host_port \
opendds_update \
/scripts/publisher.sh
sleep 5

echo "run subscriber..."
docker run \
-d --name sub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
--env "repo_ip=$repo_ip" --env "host_port=$host_port" \
-p $host_port \
opendds_update \
/scripts/subscriber.sh

