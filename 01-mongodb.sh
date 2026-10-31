#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "MongoDB repo setup"

dnf install mongodb-org -y
validate $? "MongoDB installation"

systemctl enable mongod
systemctl start mongod
validate $? "Enable and start MongoDB"


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "MongoDB bind address change"

systemctl restart mongod
validate $? "MongoDB restart"

total_time