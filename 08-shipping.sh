#!/bin/bash
app_name="shipping"
source ./common.sh

check_root

app_setup
java_setup 
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "created MySql Client"

mysql -h mysql.amireddyravi.space -uroot -pRoboShop@1 -e "use cities" &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Required Data loaded"
else 
    echo -e "Data already loaded.. $Y SKIPPING $N"
fi

app_restart
print_exec_time