#!/bin/bash

app_name=catalogue

source ./common.sh

check_root

app_setup

nodejs_setup
systemd_setup


cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "adding mongo repo"

dnf install mongodb-mongosh -y
validate $? "installing mongodb client"

product_count=$(mongosh --host "mongodb.$DOMAIN_NAME" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>>$logs_file)
validate $? "counting products in catalogue database"

if [ "$product_count" -eq 0 ]; then
    mongosh --host "mongodb.$DOMAIN_NAME" </app/db/master-data.js
    validate $? "load catalogue data"
else
echo -e "$(timestamp) [INFO] Catalogue data already exists in database...${Y}SKIPPING${N}" | tee -a "$logs_file"
fi  


restart

total_time