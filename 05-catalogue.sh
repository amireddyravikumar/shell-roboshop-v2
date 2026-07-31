#!/bin/bash
app_name="catalogue"
source ./common.sh

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Added Mongo repo" 

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installed mongodb client" 

INDEX=$(mongosh --host mongodb.amireddyravi.space --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.amireddyravi.space </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load Products"
else 
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi
app_restart
print_exec_time
