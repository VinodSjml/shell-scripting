#!/bin/bash

source components/common.sh

comp_name=mysql

echo -e "\e[32m configuring ${comp_name} .... \e[0m"
echo -n "download ${comp_name} repo: "
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "installing ${comp_name}:"
yum install mysql-community-server -y
stat $?

echo -n "starting ${comp_name} service:"
systemctl enable mysqld
systemctl start mysqld
stat $?