#!/bin/bash

set -e
user_id=$(id -u)
comp_name=catalogue
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
yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
stat $?


echo -n "installing nodejs :"
current_date=$(date)
echo -e "\n\t ${current_date}" &>> ${logfile}
yum install nodejs -y &>> ${logfile}
stat $?

echo -n "switching to service account roboshop.. "
sudo su - roboshop
user_check $?

user_check(){
       if [ $1 -ne 0 ]
          echo "adding service account roboshop"
          sudo useradd roboshop
          sudo su - roboshop
       fi
}

<<COMMENT
echo -n "updating the listening state of mongodb: "
sed -ie 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
stat $?


echo -n "enabling and starting ${comp_name} service :"
systemctl enable mongod &>> ${logfile}
systemctl start mongod &>> ${logfile}
stat $?

echo -n "donwloading ${comp_name} schema: "
curl -s -L -o /tmp/mongodb.zip "https://github.com/stans-robot-project/mongodb/archive/main.zip"
stat $?

echo -n "extracting the schema: "
cd /tmp
unzip -o mongodb.zip &>> ${logfile}
stat $?

echo -n "injecting the schema: "
cd mongodb-main
mongo < catalogue.js &>> ${logfile}
mongo < users.js &>> ${logfile}
stat $?

echo -e "\e[32m \t mongodb has been configured successfully \e[0m"
COMMENT