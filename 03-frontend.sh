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
        echo -e "$2 ... $R Failue $N"
        exit 1
    else
        echo -e  "$2 ... $G Success $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo -e "$R please run the script inside the server $N"
    exit 1
else
    echo -e "$G you are in root user $N"
fi

dnf install nginx -y   &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx  &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx    &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "remove in everything in html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "download the code"

cd /usr/share/nginx/html  &>>$LOG_FILE
VALIDATE $? "move to directory"

unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "unzip the frontend code"

cp /home/ec2-user/shell-expense/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOG_FILE
VALIDATE $? "copy the code"

systemctl restart nginx  &>>LOG_FILE
VALIDATE $? "restart the nginx"

echo -e "$G frontend server is created successfully $N"  &>>LOG_FILE
