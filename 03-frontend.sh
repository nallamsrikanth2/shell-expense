#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo "$2 ... Failue"
        exit 1
    else
        echo "$2 ... Success"
    fi
}

if [ $USERID -ne 0 ]
then
    echo " please run the script inside the server"
    exit 1
else
    echo "you are in root user"
fi

dnf install nginx -y 
VALIDATE $? "install nginx"

systemctl enable nginx
VALIDATE $? "enable nginx"

systemctl start nginx
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "remove in everything in html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "download the code"

cd /usr/share/nginx/html
VALIDATE $? "move to directory"

unzip /tmp/frontend.zip
VALIDATE $? "unzip the frontend code"

cp /home/ec2-user/shell-expense/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "copy the code"

systemctl restart nginx
VALIDATE $? "restart the nginx"

