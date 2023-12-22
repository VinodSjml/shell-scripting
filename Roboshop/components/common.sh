#!/bin/bash
   
app_user=roboshop
logfile="/tmp/${comp_name}.logs"

user_id=$(id -u)
if [ $user_id -ne 0 ]; then
     echo -e "this script installs only when it is run by a root user or with a sudo access \n\t Example: sudo bash wrapper.sh frontend"
     exit 1
fi


stat(){
    if [ $1 -eq 0 ]; then
       echo -e "\e[32m success \e[0m"
    else 
       echo -e "\e[30m failure \e[0m" 
       exit 2 
    fi 
}

create_user(){
    id ${app_user} &>> ${logfile}
if [ $? -ne 0 ]; then
         echo -n "creating an application user account ${app_user}: "
         useradd ${app_user}
         stat $?
fi
}

download_and_extract(){
    
  echo -n "copying the ${comp_name} to ${app_user}: "
  curl -s -L -o /tmp/cart.zip "https://github.com/stans-robot-project/${comp_name}/archive/main.zip"
  cd /home/${app_user}/
  rm -rf ${comp_name} &>> ${logfile}
  unzip -o /tmp/${comp_name}.zip &>> ${logfile}
  stat $?

  echo -n "changing the ownership of the ${comp_name} directory to ${app_user}: "
  cd /home/${app_user}/
  mv ${comp_name}-main ${comp_name}
  chown -R ${app_user}:${app_user} /home/${app_user}/${comp_name}/
  stat $?
}

ip_setup(){
    echo -n "configuring the mongodb ip address:"
    cd /home/${app_user}/${comp_name}/
    sed -ie 's/REDIS_ENDPOINT/redis.roboshop.internal/' systemd.service
    sed -ie 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' systemd.service
    stat $?
}

configure_service(){
    echo -n "creating a systemctl ${comp_name} artifact: "
    mv /home/${app_user}/${comp_name}/systemd.service /etc/systemd/system/${comp_name}.service
    stat $?
 
  echo -n "starting the ${comp_name} service : "
  systemctl daemon-reload
  systemctl enable ${comp_name} &>> ${logfile}
  systemctl start ${comp_name} &>> ${logfile}
  systemctl status ${comp_name} -l &>> ${logfile}
 stat $?
}

Nodejs(){
    echo -e "\e[34m configuring ${comp_name}... \e[0m"
    echo -n "downloading ${comp_name} repo : "
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash -  &>> ${logfile}
    stat $?

    create_user  #calling create_user function to create a service account

    download_and_extract #calling donwload and extract function to download files and configure it for service account
    
    echo -n "generating artifacts: "
    cd /home/${app_user}/${comp_name}/
    npm install &>> ${logfile}
    stat $?

    ip_setup #calling ip_setup to set up ip address of servers

    configure_service #create a systemctl artifact for the component
}
