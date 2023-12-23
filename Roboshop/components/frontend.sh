#!/bin/bash

set -e
user_id=$(id -u)
comp_name=frontend
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


echo -n "nginx installation status:" 
current_date=$(date)
echo -e "\n\t $current_date" &>> $logfile
yum install nginx -y &>> $logfile
stat $?

echo -n "starting nginx service: "
systemctl enable nginx &>> $logfile
systemctl start nginx &>> $logfile
stat $?

echo -n "downloading frontend: "
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"
stat $?

echo -n "sorting frontend files: " 
cd /usr/share/nginx/html
rm -rf * &>> $logfile
unzip /tmp/frontend.zip &>> $logfile
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md &>> $logfile
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

echo -n "updating backend components in reverse proxy file:"
for component in cart catalogue user shipping ; do
   sed -i -e "/${component}/s/localhost/${component}.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
done

echo -n "restarting nginx servie: "
systemctl daemon-reload
systemctl restart nginx
stat $?
