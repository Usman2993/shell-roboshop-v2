#!/bin/bash

source ./common.sh

check_root

dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y &>> $logs_file
validate $? "MySQL installation"

systemctl enable mysqld &>> $logs_file
systemctl start mysqld 
validate $? "Enable and start MySQL"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "MySQL root password setup"

echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====== Script completed execution ======" | tee -a "$logs_file"

total_time