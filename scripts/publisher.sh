#!/bin/sh
work_dir=$DDS_ROOT/DevGuideExamples/DCPS/Messenger.minimal
cd $work_dir
rm -f /scripts/pub.log
rm -f pub.ini
cp /scripts/pub.ini pub.ini
sed -i -e "s/repo_ip/$repo_ip/" -e "s/repo_port/$repo_port/" -e "s/host_ip/$host_ip/" -e "s/host_port/$host_port/" pub.ini
while :
do 
    ping -c 1 $repo_ip
    if [ $? -eq 0 ]; then
	break
    fi
    sleep 1
done    

#./publisher -ORBDottedDecimalAddresses 1 -DCPSDebugLevel 10 -ORBLogFile /scripts/pub.log  -DCPSConfigFile pub.ini
./publisher -ORBDottedDecimalAddresses 1 -ORBDebugLevel 10 -DCPSDebugLevel 10  -DCPSConfigFile pub.ini
