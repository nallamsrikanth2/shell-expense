#!/bin/bash
set -e
error_handling(){
    echo "occured at line number $1: error command:$2"
}
trap 'error_handling ${LINENO} "$BASH_COMMAND"' ERR

source ./common.sh
CHECK_ROOT

dnf install mysql-serverr -y  &>>$LOG_FILE
#VALIDATE $? "install the mysql server"

systemctl enable mysqld   &>>$LOG_FILE
#VALIDATE $? "enable mysqld"

systemctl start mysqld     &>>$LOG_FILE
#VALIDATE $? "start the mysqld"

mysql -h db.nsrikanth.online -uroot -pExpenseApp@1 -e 'show databases;'   &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    #VALIDATE $? "setup the root password"
else
    echo -e "root password alredy setup ......... $Y skipping $N"
fi

echo -e "$G db server created successfully $N"

