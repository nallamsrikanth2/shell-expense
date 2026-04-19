#!/bin/bash

USERID=$(ID -U)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $o | cut -d "-" -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo "$2 ... failure"
    else
        echo "$2 ... Sucess"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo "Please run the script inside the root user"
    exit 1
else
    echo "you are in root user"
fi

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable the nodejs"

dnf install nodejs -y    &>>$LOG_FILE
VALIDATE $? "install nodejs"

id expense
if [ $? -eq 0 ]
then 
    echo "user already created ... $Y skipping $N"
    exit 1
else
    useradd expense   &>>$LOG_FILE
    VALIDATE $? "create the useradd"
fi

mkdir -p /app   &>>$LOG_FILE
VALIDATE $? "creating the directory app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "download the backend code"

cd /app   &>>$LOG_FILE
VALIDATE $? "move to cd app"
rm -rf /app/*  &>>LOG_FILE
VALIDATE $? "remove everything in app"

unzip /tmp/backend.zip  &>>$LOG_FILE
VALIDATE $? "unzip the file"

cd /app   &>>$LOG_FILE
VALIDATE $? "move to cd"

npm install   &>>$LOG_FILE
VALIDATE $? "npm install"

cp /home/ec2-user/shell-expense /etc/systemd/system/backend.service   &>>$LOG_FILE
VALIDATE $? "copy the code"

systemctl daemon-reload   &>>$LOG_FILE
VALIDATE $? "reload the code"

systemctl start backend    &>>$LOG_FILE
VALIDATE $? "start the backend"

systemctl enable backend    &>>$LOG_FILE
VALIDATE $? "enable backend"

echo -e "$G  bakend sever is created sucessfully $N"




