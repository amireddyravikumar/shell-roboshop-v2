#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySql Server"

systemctl enable mysqld &>> $LOG_FILE
systemctl start mysqld &>> $LOG_FILE  
VALIDATE $? "starting and enabling MySql Server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up root password"

print_exec_time