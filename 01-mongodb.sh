#!/bin/bash
app_name="mongodb"
source ./common.sh

# check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing Mongo DB"

systemctl enable --now mongod 
VALIDATE $? "starting and enabling Mongo DB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Allowing remote connection to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"