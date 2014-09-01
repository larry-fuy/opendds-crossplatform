#!/bin/sh
# 1) Check the version of
#      Docker : 1.1.2
#      Vagrant : 1.6.3
#      VBox : 4.3.14
#      Kernel : 3.15.10
# 2) Run VBox for repo
docker_ver=1.1.2
vagrant_ver=1.6.3
vbox_ver=4.3.14
# kernel version is not a strict requirement 
#kernel_ver=3.15.10

# return 0 if version is equal or greater than check 
check_version()
{
    local version=$1 check=$2
    if  [[ "$version" = "$check" ]]; then
	echo 0
    else 
	local winner=$(printf "$version\n$check\n" | sort -V | head -1)
	if [[ "$winner" = "$check" ]]; then 
	    echo 0
	else
	    echo 1
        fi
    fi
}

upgrade=0
# compare Docker version
ver=$(docker -v | gawk '{ print $3 }' | sed 's\,\\g')
return_ver=$(check_version $ver $docker_ver)
if [[ $return_ver -ne 0 ]]; then
  echo "Docker Version $ver must be greater than $docker_ver"
  upgrade=1
fi

# compare Vagrant version
ver=$(vagrant -v | gawk '{ print $2 }')
return_ver=$(check_version $ver $vagrant_ver)
if [[ $return_ver -ne 0 ]]; then
  echo "Vagrant Version $ver must be greater than $docker_ver"
  upgrade=1
fi

# compare VirtualBox version
ver=$(vboxmanage -v | gawk -F "_" '{print $1}')
return_ver=$(check_version $ver $vagrant_ver)
if [[ $return_ver -ne 0 ]]; then
  echo "Vagrant Version $ver must be greater than $docker_ver"
  upgrade=1
fi

if [ $upgrade -eq 1 ]; then
    echo "Please upgrade the required package first..."
    exit
fi

# Let linux kernel forward the packet
forward=$(cat /proc/sys/net/ipv4/ip_forward)
if [ $forward -eq 0 ]; then
    sudo 'echo 1 > /proc/sys/net/ipv4/ip_forward' 
fi

case "$1" in
    -h)
	echo "Syntax:"
	echo "run_test [repo_port] [host_port]"
	exit 1
      ;;
esac

repo_port=$1
[ "$repo_port" ] ||  repo_port=15000
host_port=$2
[ "$host_port" ] ||  host_port=1234 

# start vagrant box for inforepo
echo "run inforepo..."
# edit Vagrantfile to replace the ip address
vm_name=repo_vm
sed -e "s/repo_port/$repo_port/g" \
-e "s/vm_name/$vm_name/g" \
 Vagrant_template > Vagrantfile

eval "ip addr show vboxnet0 > /dev/null"
if [[ $? -ne 0 ]]; then
    vboxmanage hostonlyif create
fi

#eval "has_dds=$(vagrant box list | grep \'^dds\')"
vagrant box list | grep '^dds'
if [[ $? -ne 0 ]]; then 
    # Todo : import the box automatically
    echo "Add the dds box first..."
    vagrant box add --name /home/yfu/projects/vagrant/opendds-crossplatform/dds.box
    exit 1
fi
vagrant up --no-provision


# collect ip of host-only network interface in virtualbox
echo "reset network..."
vnet=$(vboxmanage showvminfo repo_vm | grep "NIC.*Host-only" | gawk '{print $8}' | sed -e "s/'//g" -e "s/,//g")
repo_gateway=$(ip addr show $vnet | grep -w inet | gawk '{print $2}' | sed 's/\/24//')
repo_ip=$(echo $repo_gateway | gawk -F. '{print $1"."$2"."$3"."$4+1}')
sed -e "s/repo_port/$repo_port/g" \
-e "s/repo_ip/$repo_ip/g" \
-e "s/repo_gateway/$repo_gateway/g" \
 ./scripts/run_dds_win_template.bat > ./scripts/run_dds_win.bat
vagrant provision &
#debug : rdesktop -u vagrant 127.0.0.1:3389 &

echo "wait a moment for inforepo starting..."
sleep 30

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

echo "run publisher..."
docker run \
-d --name pub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
--env "repo_ip=$repo_ip"  --env "host_port=$host_port" \
-p $host_port \
yongfu/opendds \
/scripts/publisher.sh
sleep 5
#dds_nettools /bin/bash
#yongfu/opendds 

echo "run subscriber..."
# docker run -d --name publisher -e "repo_ip=$repo_ip" -e "repo_port=$repo_port" -e "host_port=$host_port"  -v "$PWD/scripts:/scripts"  -w /scripts yongfu/opendds /scripts/publisher.sh > /dev/null 2>&1
docker run \
-d --name sub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
--env "repo_ip=$repo_ip" --env "host_port=$host_port" \
-p $host_port \
yongfu/opendds \
/scripts/subscriber.sh
#dds_nettools /bin/bash
