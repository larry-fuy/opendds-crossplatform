#!/bin/sh
rm -f /scripts/pub.log
touch /scripts/pub.log
exec 1> /scripts/pub.log

cd /opt/trunk && chmod +x ./setenv.sh && . ./setenv.sh 
work_dir="$DDS_ROOT/DevGuideExamples/DCPS/Messenger.minimal"
host_ip=$(hostname -i)
rm -f /scripts/pub.ini
cp /scripts/pub_template.ini /scripts/pub.ini
echo "generate ini..."
sed -i -e "s/repo_ip/$repo_ip/" -e "s/repo_port/$repo_port/" -e "s/host_ip/$host_ip/" -e "s/host_port/$host_port/" /scripts/pub.ini
while :
do 
    if nc -v -n $repo_ip $repo_port 2>&1 | grep -q succeeded; then
	break
    fi
    sleep 1
    echo "waiting inforepo..."
done    
echo "start running publisher..."
rm -f /scripts/pub_run.log
touch /scripts/pub_run.log
$work_dir/publisher -ORBDottedDecimalAddresses 1 -DCPSDebugLevel 10 -ORBLogFile /scripts/pub_run.log -DCPSConfigFile /scripts/pub.ini
