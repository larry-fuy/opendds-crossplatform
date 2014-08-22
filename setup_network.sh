#!/bin/sh
# static ips for InfoRepo, Publisher and Subscriber
net_ip=172.19.0.1

# rebuild vbox bridge to let it connect to docker bridge
brctl show | grep vboxnet0
if [ "$?" -ne 0 ]; then
    # if vboxnet0 is created by VirtualBox, delete it
    ifconfig vboxnet0 > /dev/null 2 >&1
    if [ "$?" -eq 0 ] ; then
	echo "Delete vboxnet0 created by VirtualBox..."
	ifconfig vboxnet0 down
	vboxmanage hostonlyif remove vboxnet0
    fi
else 
    echo "Delete old vboxnet0..."
    ifconfig vboxnet0 down
    brctl delbr vboxnet0
fi
echo "Add new vboxnet0..."
brctl addbr vboxnet0
ifconfig vboxnet0  broadcast 
ifconfig vboxnet0 $net_ip netmask 255.255.0.0 up

# start Virtualbox to fill the new vboxnet0
vboxmanage list hostonlyifs | grep vboxnet0
if [ "$?" -eq 1 ]; then
    echo "something wrong, check network configuration..."
fi

