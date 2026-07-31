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
echo -e "$TIMESTAMP [INFO] Script started:"

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

copy_repo(){
    cp $app_name.repo /etc/yum.repos.d/$app_name.repo
    VALIDATE $? "Adding $app_name Repo"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "created systemctl service"
    
    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enabled $app_name"
}
app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else 
        echo -e "System user roboshop already created.. $Y SKIPPING $N" 
    fi

    rm -rf /app
    VALIDATE $? "Removing existing code"

    rm -rf /tmp/$app_name.zip
    VALIDATE $? "Removed $app_name zip"

    mkdir -p /app  &>>$LOG_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Downloaded and extracted $app_name code"
}
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS:20"
    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies"
}

app_restart(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restarting $app_name"
}
java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package  &>>$LOGS_FILE
    mv target/$app_name-1.0.jar $app_name.jar 
    VALIDATE $? "Installing dependencies"
}
python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"
    
    pip3 install -r requirements.txt  &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}