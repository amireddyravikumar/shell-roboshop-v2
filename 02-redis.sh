#!/bin/bash

source ./common.sh

check_root
 
dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y &>> $LOG_FILE
dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection to Redis"

systemctl enable --now redis &>> $LOG_FILE
VALIDATE $? "starting and enabling Redis"

print_exec_time