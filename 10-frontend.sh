#!/bin/bash
app_name="frontend"
source ./common.sh

check_root
 
dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installed nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing existing code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE 
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE 
VALIDATE $? "Downloaded and extracted fronend code"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied robosop nginx conf"
 

systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Enabled and Restarted NGINX"

print_exec_time