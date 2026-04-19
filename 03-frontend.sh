#!/bin/bash
source ./common.sh
CHECK_ROOT

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
