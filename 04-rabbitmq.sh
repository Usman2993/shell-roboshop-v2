#!/bin/bash

source ./common.sh

check_root



cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $logs_file
validate $? "RabbitMQ repo setup"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "RabbitMQ installation"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Enable and start RabbitMQ"

rabbitmqctl list_users | grep -qw "roboshop" &>> $logs_file
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
    validate $? "RabbitMQ user creation"
else
    echo -e "$(timestamp) [INFO] RabbitMQ user already exists...${Y}SKIPPING${N}" | tee -a "$logs_file"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "RabbitMQ user setup"


total_time