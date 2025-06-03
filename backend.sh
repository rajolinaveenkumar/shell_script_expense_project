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

dnf module disable nodejs -y
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling nodejs:20"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "expense user" expense
    VALIDATE $? "Creating expense user"
else
    echo -e "$Y expense user is allready exist $N"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "expense content download"

cd /app
VALIDATE $? "redirect to /app"

rm -rf /app/*
VALIDATE $? "Deleting existing content in /app directory"