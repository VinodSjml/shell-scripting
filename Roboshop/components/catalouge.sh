#!/bin/bash

set -e
user_id=$(id -u)
comp_name=catalogue
app_user=roboshop
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
yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y &>> ${logfile}
stat $?


echo -n "installing nodejs :"
current_date=$(date)
echo -e "\n\t ${current_date}" &>> ${logfile}
yum install nodejs -y &>> ${logfile}
stat $?

id ${app_user} &>> ${logfile}
if [ $? -ne 0 ]; then
         echo -n "creating an application user account ${app_user}: "
         useradd ${app_user}
         stat $?
fi

echo -n "copying the ${comp_name} to ${app_user}: "
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/catalogue/archive/main.zip"
cd /home/${app_user}
rm -rf ${comp_name} &>> ${logfile}
unzip -o /tmp/catalogue.zip &>> ${logfile}
stat $?

echo -n "changing the ownership of the ${comp_name} directory to ${app_user}: "
cd /home/${app_user}
mv catalogue-main catalogue
chown -R ${app_user}:${app_user} /home/${app_user}/${comp_name}/
stat $?

echo -n "generating artifacts: "
cd /home/${app_user}/${comp_name}
npm install &>> ${logfile}
stat $?

echo -n "configuring the mongodb ip address:"
cd /home/${app_user}/${comp_name}/
sed -ie 's/MONGO_DNSNAME/mongodb.roboshop.internal/' systemd.service
stat $?

echo -n "creating a systemctl ${comp_name} artifact: "
mv /home/${app_user}/${comp_name}/systemd.service /etc/systemd/system/${comp_name}.service
stat $?

echo -n "starting the ${comp_name} service : "
systemctl daemon-reload
systemctl enable ${comp_name} &>> ${logfile}
systemctl start ${comp_name} &>> ${logfile}
systemctl status ${comp_name} -l &>> ${logfile}
stat $?

echo -e "\e[32m \t ${comp_name} has been configured successfully \e[0m"
