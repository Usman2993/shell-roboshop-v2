#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
DOMAIN_NAME="usdaws92s.store"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
if [ $user_id -ne 0 ]; then
    echo "Please run the script with sudo access"
    exit 1   
fi
}

mkdir -p $logs_folder

echo "Script started execution at $(date +"%F %T")"

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${2}..${R} failed${N}" | tee -a "$logs_file"
        exit 1
    else 
        echo -e "${2}..${G} successful${N}" | tee -a "$logs_file"
    fi
}

timestamp(){
    date +"%F %T"
}    

nodejs_setup(){
    dnf module disable nodejs -y &>> $logs_file
    dnf module enable nodejs:24 -y &>> $logs_file
    dnf install nodejs -y &>> $logs_file
    validate $? "NodeJS installation"  

    npm install &>> $logs_file
    validate $? "Roboshop $app_name dependencies installation"                     
}   

java_setup(){
        dnf module enable maven:3.9 -y &>> $logs_file
    dnf install maven java-25-openjdk-devel -y &>> $logs_file
    validate $? "Maven and Java installation"

    alternatives --set java "//usr/lib/jvm/java-25-openjdk/bin/java" &>> $logs_file
    validate $? "Java alternatives setup java 25 as default"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "setting JAVA_HOME for maven"
    mvn clean package &>> $logs_file
    validate $? "Roboshop user dependencies installation"

    mv target/shipping.jar shipping.jar
    validate $? "Roboshop shipping jar rename"
}

python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $logs_file
    validate $? "Python3.14 installation"
    
    python3.14 -m venv /app/.venv &>> $logs_file
    validate $? "Roboshop payment virtual environment setup"

    /app/.venv/bin/pip install -r requirements.txt &>> $logs_file
    validate $? "Roboshop payment dependencies installation"
}

app_setup(){
        id roboshop &>> $logs_file
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
        validate $? "Roboshop system user creation"
    else
        echo -e "$(timestamp) [INFO] Roboshop system user already exists...${Y}SKIPPING${N}" | tee -a "$logs_file"
    fi  

    rm -rf /app &>> $logs_file
    validate $? "Roboshop application folder cleanup"

    mkdir -p /app
    validate $? "Roboshop application folder creation"

    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $logs_file
    validate $? "Roboshop $app_name artifact download"

    cd /app
    unzip "/tmp/$app_name.zip" &>> $logs_file
    validate $? "Roboshop $app_name artifact unzip" 
}   

systemd_setup(){
    sed -i -e "s/DOMAIN_NAME/${DOMAIN_NAME}/" "$scripts_dir/$app_name.service" &>> "$logs_file"
    validate $? "$app_name service configuration"

    cp "$scripts_dir/$app_name.service" /etc/systemd/system/$app_name.service &>> "$logs_file"
    validate $? "Roboshop $app_name systemd service file setup"

    systemctl daemon-reload &>> $logs_file
    systemctl enable $app_name &>> $logs_file
    systemctl start $app_name &>> $logs_file
    validate $? "Enable and start Roboshop $app_name service"
}

restart(){
    systemctl restart $app_name &>> $logs_file
    validate $? "Roboshop $app_name service restart"
}

total_time(){
echo -e "$(timestamp) [INFO] time taken $SECONDS seconds ============" | tee -a "$logs_file"
echo -e "$(timestamp) [INFO] ====== Script completed execution ======" | tee -a "$logs_file"}
}