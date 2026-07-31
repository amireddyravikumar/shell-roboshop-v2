#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
echo -e "$TIMESTAMP [INFO] Script started: $SECONDS"

# if [ $USERID -ne 0 ]; then
#     echo -e "$R Please run with root access $N" | tee -a $LOG_FILE
#     exit 1
# fi
check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run with root access $N" | tee -a $LOG_FILE
        exit 1
    fi
}
function VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2...  $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$TIMESTAMP [INFO] $2... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

print_exec_time(){
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "$TIMESTAMP [INFO] Script executed in $G $SECONDS seconds $N"
}