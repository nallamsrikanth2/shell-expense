#!/bin/bash

USERID=$(id -u)
TIMESTAP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAP.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$R $2 .... failue $N"
        exit 1
    else
        echo -e "$G $2 .... Sucsess $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo -e " $R please run inside the root user $N"
    exit 1
else
    echo -e " $G you are in root user $N"
fi

dnf install mysql-server -y  &>>$LOG_FILE
VALIDATE $? "install the mysql server"

systemctl enable mysqld   &>>$LOG_FILE
VALIDATE $? "enable mysqld"

systemctl start mysqld     &>>$LOG_FILE
VALIDATE $? "start the mysqld"

mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 -e 'showdatabases;'   &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1"
    VALIDATE $? "setup the root password"
else
    echo -e "root password alredy setup ......... $Y skipping $N"
fi

