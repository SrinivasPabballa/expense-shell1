#!/bin/bash

USERID=$( id -u )
TIMESTAMP=$( date +%f-%h-%m-%s)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=$/tmp/SCRIPT_NAME-TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo "Please run with superuser"
    exit 1
else 
    echo "You are superuser"
fi 

VALIDATE (){

    if [ $1 -ne 0 ]
    then 
        echo -e "$2..$R FAILURE $N"
    else 
        echo -e "$2..$G SUCCESS $N" 
   fi      
}       

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling nodejs" 

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE  $? "Enabling  nodejs 20" 

dnf install nodejs -y  &>>LOGFILE 
VALIDATE  $? "Installing nodejs"

id expense &>>LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>LOGFILE 
    VALIDATE $? "Creating useradd expense"
else 
    echo -e "User already exists.. $Y SKIPPING $N"    
fi 

mkdir -p /app
VALIDATE  $? "Creating a directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>LOGFILE 
VALIDATE  $? "Downloading the code"

cd /app
unzip /tmp/backend.zip &>>LOGFILE 
VALIDATE  $? "Unzipping backend"

cd /app
npm install &>>LOGFILE 
VALIDATE  $? "Downloading the dependencies"




