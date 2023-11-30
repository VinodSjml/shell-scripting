#!/bin/bash

set -e
user_id=$(id -u)
if [ $user_id -ne 0 ]; then
     echo -e "this script installs only when it is run by a root user or with a sudo access \n\t Example: sudo bash wrapper.sh frontend"
     exit 1
fi

echo -e "\e[34m configuring frontend... \e[0m"

stat(){
    if [ $1 -eq 0 ]; then
       echo -e "\e[32m success \e[0m"
    else 
       echo -e "\e[32m failure \e[0m" 
       exit 2 
    fi 
}

echo -n "nginx installation status:" 
yum install nginx -y &>> /tmp/frontend.logs
stat $?

echo -n "starting nginx service: "
systemctl enable nginx &>> /tmp/frontend.logs
systemctl start nginx &>> /tmp/frontend.logs
stat $?

echo -n "downloading frontend: "
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"
stat $?

echo -n "sorting frontend files: " 
cd /usr/share/nginx/html
rm -rf * &>> /tmp/frontend.logs
unzip /tmp/frontend.zip &>> /tmp/frontend.logs
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md &>> /tmp/frontend.logs
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

echo -n "restarting nginx servie: "
systemctl daemon-reload
systemctl restart nginx
stat $?
