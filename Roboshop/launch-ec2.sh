#!/bin/bash

component=$1
if [ -z $1 ]; then
    echo "please enter the component name as an argument"
    exit 1
fi

ami_id=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq ".Images[].ImageId" | sed -e 's/"//g')
instance_type="t2.micro"
secgrp_id="sg-008477cb2de2ff3b0"

echo -e "\e[32m launching ${component} server \e[0m"
private_ip=$(aws ec2 run-instances --image-id ${ami_id} --count 1 --instance-type ${instance_type} --security-group-ids ${secgrp_id} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${component}}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')
echo "${component} server has been launched and its private ip is ${private_ip}"
