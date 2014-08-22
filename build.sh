#!/bin/sh
# This script tries to run the OpenDDS cross-platform test
# Currently only Linux (Ubuntu) and Windows are considered
# steps:
# 1) setup network (setup_network)
# 2) start Docker container to run InfoRepo and publisher
# 3) start Vagrant to run subcriber
# 4) clean. 

# static ips for InfoRepo, Publisher and Subscriber
net_ip=172.19.0.1
repo_ip=172.19.0.2
pub_ip=172.19.0.3
sub_ip=172.19.0.4

repo_port=10000
host_port=1234

# start vagrant box for inforepo
# edit Vagrantfile to replace the ip address
echo "run inforepo..."
vagrant box list | grep '^dds'
if [ $? -ne 0 ]; then 
    # Todo : import the box automatically
    echo "Add the dds box first..."
    vagrant box add --name /home/yfu/projects/vagrant/opendds-crossplatform/dds.box
    exit 1
fi
vagrant up 

# debug windows box
#rdesktop -u vagrant 127.0.0.1:3389 &

echo "clearing containers..."
sudo docker stop  pub sub
sudo docker rm   pub sub

echo "run publisher..."
sudo docker run \
-d --name pub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
-e "repo_ip=$repo_ip" -e "repo_port=$repo_port" -e "host_ip=$pub_ip" -e "host_port=$host_port" \
--net="bridge" \
--lxc-conf="lxc.network.type = veth" \
--lxc-conf="lxc.network.ipv4 = $pub_ip" \
--lxc-conf="lxc.network.ipv4.gateway = $net_ip" \
--lxc-conf="lxc.network.link = vboxnet0" \
--lxc-conf="lxc.network.name = eth0" \
--lxc-conf="lxc.network.flags = up" \
dds_nettools /bin/bash
#yongfu/opendds 
#/scripts/publisher.sh

echo "run subscriber..."
# docker run -d --name publisher -e "repo_ip=$repo_ip" -e "repo_port=$repo_port" -e "host_port=$host_port"  -v "$PWD/scripts:/scripts"  -w /scripts yongfu/opendds /scripts/publisher.sh > /dev/null 2>&1
sudo docker run \
-d --name sub -v "$PWD/scripts:/scripts" -w /scripts --env "repo_port=$repo_port" \
-e "repo_ip=$repo_ip" -e "repo_port=$repo_port" -e "host_ip=$sub_ip" -e "host_port=$host_port" \
--net="bridge" \
--lxc-conf="lxc.network.type = veth" \
--lxc-conf="lxc.network.ipv4 = $sub_ip" \
--lxc-conf="lxc.network.ipv4.gateway = $net_ip" \
--lxc-conf="lxc.network.link = vboxnet0" \
--lxc-conf="lxc.network.name = eth0" \
--lxc-conf="lxc.network.flags = up" \
dds_nettools /bin/bash
#yongfu/opendds 
#/scripts/subscriber.sh

#vagrant provision


# # # stop and clean 
# # echo "clean up..."
# # docker stop ${names[*]} > /dev/null 2>&1
# # docker rm ${names[*]} > /dev/null 2>&1

#vagrant halt
# # vagrant destroy


