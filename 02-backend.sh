#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2 ... $R failure $N"
        exit 1
    else
        echo -e "$2 ... $G Sucess $N"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo -e "$R Please run the script inside the root user $N"
    exit 1
else
    echo -e "$G you are in root user $N"
fi

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