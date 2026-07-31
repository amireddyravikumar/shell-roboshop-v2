#!/bin/bash
app_name="rabbitmq"
source ./common.sh

check_root

copy_repo

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOG_FILE
systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting and enabling RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "settng uo the user and password for RabbitMQ Server"

print_exec_time