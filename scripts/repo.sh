#!/bin/sh
repo_ip=$(hostname -i)
echo $repo_ip
work_dir=$DDS_ROOT/DevGuideExamples/DCPS/Messenger.minimal
cd $work_dir
pwd
rm -f repo.log repo.ior
rm -f /scripts/repo.log /scripts/repo.ior
while :
do 
    ping -c 1 $sub_ip
    if [ $? -eq 0 ]; then
	break
    fi
    sleep 1
done    

$DDS_ROOT/bin/DCPSInfoRepo -DCPSDebugLevel 10 -ORBLogFile /scripts/repo.log  -ORBListenEndpoints iiop://"$repo_ip:$repo_port"
