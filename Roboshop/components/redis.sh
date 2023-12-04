#!/bin/bash

set -e
user_id=$(id -u)
comp_name=redis
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
curl -L https://raw.githubusercontent.com/stans-robot-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo
stat $?

echo -n "installing ${comp_name} :"
current_date=$(date)
echo -e "\n\t ${current_date}" &>> ${logfile}
yum install redis-6.2.13 -y &>> ${logfile}
stat $?

echo -n "updating the listening state of ${comp_name}: "
sed -ie 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
sed -ie 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
stat $?

echo -n "enabling and starting ${comp_name} service :"
systemctl daemon-reload
systemctl enable redis &>> ${logfile}
systemctl start redis &>> ${logfile}
systemctl status redis &>> ${logfile}
stat $?


echo -e "\e[32m \t ${comp_name} has been configured successfully \e[0m"
