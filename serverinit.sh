#!/bin/bash

curl -s https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh >/tmp/common-functions.sh
source /tmp/common-functions.sh

CheckRoot

CheckOS 7

which gcloud &>/dev/null
Stat $? "Checking Google Cloud CLI"

HNAME=$(hostname)
gcloud compute instances list 2>/dev/null| grep $HNAME &>/dev/null
if [ $? -ne 0 ]; then 
    PrintCenter "Please Open the coming URL, to create the and setup the LAB. Open the URL, and get the code and Paste it here"
    echo -e "\e[33m"
    gcloud auth login --quiet --brief
    gcloud compute instances list | grep $HNAME &>/dev/null
    if [ $? -ne 0 ]; then 
        Stat 1 "Provided Key is Wrong"
    fi 
fi 

PROJECT=$(gcloud config list --format 'value(core.project)')
IMAGE=$(gcloud compute images list | grep centos-7 | awk '{print $1}')

info "Checking Pre-requisites"
gcloud compute instances list 2>/dev/null | grep imaging &>/dev/null
if [ $? -eq 0 ]; then 
    gcloud compute instances delete imaging --quiet &>/dev/null 
    sleep 60
fi

gcloud compute instances create imaging --zone=us-east1-b --machine-type=n1-standard-1 --metadata=startup-script=curl\ -s\ https://raw.githubusercontent.com/linuxautomations/scripts/master/init.sh\ \|\ sudo\ bash --image=$IMAGE --image-project=centos-cloud --boot-disk-size=10GB &>/dev/null
Stat $? "Started making Image"


while true ; do 
a=1
for i in \| \/ \- \\ \| \/ \- \\ ; do 
    [ $a -gt 8 ] && break
    (echo -n > /dev/tcp/instance-2/22 ) &>/dev/null
    [ $? -eq 0 ] && A=0 && break 
	echo -en "Waiting for SSH Connection .. $i \r"
	sleep 0.25
    a=$(($a+1))
done
[ -n "$A" ] && break
done



