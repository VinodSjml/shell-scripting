#!/bin/bash

source components/common.sh

comp_name=mysql

echo -e "\e[32m configuring ${comp_name} .... \e[0m"
echo -n "download ${comp_name} repo: "
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "installing ${comp_name}:"
yum install mysql-community-server -y &>> ${logfile}
stat $?

echo -n "starting ${comp_name} service:"
systemctl enable mysqld &>> ${logfile}
systemctl start mysqld &>> ${logfile}
stat $?

echo -n "exctracting default password for mysql: "
default_password=$(grep "password" /var/log/mysqld.log | awk -F " " '{print $NF}')
stat $?

echo "show databases;" |mysql -uroot -pRoboShop@1
if [ $? -ne 0 ]; then
   echo -n "changing the default password: "
   echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1'" | mysql --connect-expired-password -uroot -p$default_password &>> ${logfile}
   stat $?
fi