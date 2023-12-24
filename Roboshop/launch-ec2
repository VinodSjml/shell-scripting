#!/bin/bash

component=$1
if [ -z $1 ]; then
    echo "please enter the component name as an argument"
    exit 1
fi

ami_id = "ami-0f75a13ad2e340a58"
instance_type = "t2.micro"
secgrp_id = "sg-008477cb2de2ff3b0"

echo -e "\e[32m launching ${component} server \e[0m"
aws ec2 run-instances --image-id ${ami_id} --count 1 --instance-type ${instance_type} --security-group-ids sg-903004f8 --tags Key=Name,Value=${component}
