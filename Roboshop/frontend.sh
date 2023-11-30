#!/bin/bash

set -e

if [ $uid -ne 0 ]; then
     echo -e "this script installs only when it is run by a rot user or with a sudo access \n\t Example: sudo bash wrapper.sh frontend"
fi

echo -e "\e[34m configuring frontend... \e[0m"

stat(){
    if [ $1 -eq 0 ]; then
       echo -e "\e[32m success \e[0m"
    else 
       echo -e "\e[32m failure \e[0m"   
}

yum install nginx -y &>> /tmp/frontend.logs
echo -n "nginx installation status:" 
stat $?

