#!/bin/bash

comp_name = rabbitmq

source components/common.sh

echo "configuring rabbitmq..."

echo -n "downloading erlang for rabbitmq:"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>> ${logfile}
stat $?

echo -n "setting up yum repo: "
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> ${logfile}
stat $?

echo -n "installing & setting up rabbitmq:"
yum install rabbitmq-server -y &>> ${logfile}
systemctl enable rabbitmq-server &>> ${logfile}
systemctl start rabbitmq-server &>> ${logfile}
systemctl status rabbitmq-server -l &>> ${logfile}
stat $?

echo -n "validating if user account already exists: "
rabbitmqctl list_users | grep roboshop
if [ $? -ne 0 ] ; then
    echo -n "creating user account for rabbitmq:"
    rabbitmqctl add_user roboshop roboshop123
    stat $?
else 
    echo "user account already exists"
fi

echo -n "setting up permissions:"
rabbitmqctl set_user_tags roboshop administrator
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
stat $?

echo "rabbitmq has been configured successfully"



