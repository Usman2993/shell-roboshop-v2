#!/bin/bash

source ./common.sh
check_root

dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y
validate $? "Nginx installation"

systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Enable and start Nginx"

rm -rf /usr/share/nginx/html/*
validate $? "Nginx default content cleanup"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
cd /usr/share/nginx/html &>> $logs_file
unzip /tmp/frontend.zip &>> $logs_file
validate $? "Roboshop frontend artifact unzip"

sed -i -e "s/DOMAIN_NAME/${DOMAIN_NAME}/" "$scripts_dir/roboshop.conf" &>> "$logs_file"
validate $? "Frontend configuration"

cp "$scripts_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf &>> "$logs_file"
validate $? "Roboshop frontend configuration file setup"

nginx -t &>> $logs_file
validate $? "Nginx configuration test"

systemctl restart nginx &>> $logs_file
validate $? "Nginx service restart"


total_time