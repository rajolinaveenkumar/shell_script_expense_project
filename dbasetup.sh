#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
UL="\e[4m"

mkdir -p "/var/log/shell_logs"

LOG_FOLDER="/var/log/shell_logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R  $2 is ............FAILURE $N"
        exit 1
    else
        echo -e "$G $2 is ............SUCCESS $N"
    fi
}

echo "$0 Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_USER(){
    if [ $USERID -ne 0 ]
    then
        echo -e "ERROR:: $UL You must have sudo access to execute this script $N"
        exit 1 # other than 0
    else 
        echo -e "$G Script name: $0 is executing..... $N"
    fi
}

CHECK_USER


dnf list installed mysql &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then 
    dnf install mysql-server -y &>>$LOG_FILE_NAME
    VALIDATE $? "Installing MYSQL"
else
    echo -e "$Y MySQL is already ... INSTALLED $N" 
fi 

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling MYSQL service"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "start MYSQL service"

echo "Please enter your database password::"
read -s PASSWORD
echo "please enter your pswd: $PASSWORD"

mysql -h 172.31.37.235 -u root -p$PASSWORD -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo -e "$Y mysql root password not set $N"
    mysql_secure_installation --set-root-pass $PASSWORD &>>$LOG_FILE_NAME
    VALIDATE $? "setting mysql root password"
else
    echo -e " $Y MYSQL ROOT PASSWORD ALLREADY SET!!!!! $N"
fi

