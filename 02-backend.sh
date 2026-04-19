#!/bin/bash

CHECK_ROOT

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y   &>>$LOG_FILE
VALIDATE $? "install nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "create user"
else
    echo -e "user already created .... $Y Skipping $N"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "create the app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip   &>>$LOG_FILE
VALIDATE $? "download the backend code"

cd /app  &>>$LOG_FILE
VALIDATE $? "move to app directory"

rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "remove the files in app directory"

unzip /tmp/backend.zip  &>>$LOG_FILE
VALIDATE $? "unzip the backend code"

cd /app  &>>$LOG_FILE

npm install  &>>$LOG_FILE
VALIDATE $? "install the libries and dependies"

cp /home/ec2-user/expense/backend.service   /etc/systemd/system/backend.service  &>>$LOGFILE

systemctl daemon-reload   &>>$LOG_FILE
VALIDATE $? "realod the code"

systemctl start backend   &>>$LOG_FILE
VALIDATE $? "start the backend"

systemctl enable backend   &>>$LOG_FILE
VALIDATE $? "enable the code"

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOG_FILE
VALIDATE $? "load the mysql schema"

systemctl restart backend   &>>$LOG_FILE
VALIDATE $? "restart backend server"