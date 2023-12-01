#!/bin/bash

set -e
user_id=$(id -u)
comp_name=mongodb
logfile="/tmp/${comp_name}.logs"
if [ $user_id -ne 0 ]; then
     echo -e "this script installs only when it is run by a root user or with a sudo access \n\t Example: sudo bash wrapper.sh frontend"
     exit 1
fi

echo -e "\e[34m configuring ${comp_name}... \e[0m"

stat(){
    if [ $1 -eq 0 ]; then
       echo -e "\e[32m success \e[0m"
    else 
       echo -e "\e[32m failure \e[0m" 
       exit 2 
    fi 
}

echo -n "downloading ${comp_name} repo : "
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/stans-robot-project/mongodb/main/mongo.repo
stat $?

echo -n "installing ${comp_name} :"
current_date=$(date)
echo -e "\n\t ${current_date}" &>> ${logfile}
yum install -y mongodb-org &>> ${logfile}
stat $?

echo -n "enabling and starting ${comp_name} service :"
systemctl enable mongod 
systemctl start mongod
stat $?