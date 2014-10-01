#!/bin/sh
rm -f /scripts/sub.log
touch /scripts/sub.log
exec 2>&1 > /scripts/sub.log

cd /opt/trunk && chmod +x ./setenv.sh && . ./setenv.sh
work_dir="$DDS_ROOT/DevGuideExamples/DCPS/Messenger.minimal"
host_ip=$(hostname -i)
rm -f /scripts/sub.ini
cp /scripts/sub_template.ini /scripts/sub.ini
echo "generate ini..."
sed -i -e "s/repo_ip/$repo_ip/" -e "s/repo_port/$repo_port/" -e "s/host_ip/$host_ip/" -e "s/host_port/$host_port/" /scripts/sub.ini
while :
do 
    if  nc -v -n $repo_ip $repo_port 2>&1 | grep -q succeeded ; then
	break
    fi
    sleep 1
    echo "waiting inforepo..."
done    
echo "start running subscriber..."
rm -f /scripts/sub_run.log
touch /scripts/sub_run.log
$work_dir/subscriber -ORBDottedDecimalAddresses 1 -DCPSDebugLevel 10  -ORBLogFile /scripts/sub_run.log -DCPSConfigFile /scripts/sub.ini > /scripts/received_message.txt
