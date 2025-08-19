#!/bin/bash

USERID=$( id -u )
TIMESTAMP=$( date +%f-%h-%m-%s)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$TIMESTAMP-$SCRIPTNAME.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please provide DB Password: " 
read  "mysql_root_password"

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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling nodejs" 

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE  $? "Enabling  nodejs 20" 

dnf install nodejs -y  &>>$LOGFILE 
VALIDATE  $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE 
    VALIDATE $? "Creating useradd expense"
else 
    echo -e "User already exists.. $Y SKIPPING $N"    
fi 

mkdir -p /app &>>$LOGFILE 
VALIDATE  $? "Creating a directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGFILE 
VALIDATE  $? "Downloading the code"

cd /app
rm -rf /app/* 
unzip /tmp/backend.zip &>>$LOGFILE 
VALIDATE  $? "Unzipping backend"

cd /app
npm install &>>$LOGFILE 
VALIDATE  $? "Downloading the dependencies"

cp /home/ec2-user/expense-shell1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE 
VALIDATE  $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE 
VALIDATE  $? "validate daemon reload" 

systemctl start backend &>>$LOGFILE 
VALIDATE  $? "Starting backend" 

systemctl enable backend &>>$LOGFILE 
VALIDATE  $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE 
VALIDATE  $? "Installing Mysql"

mysql -h db.daws-78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE  
VALIDATE  $? "Schema loading" 

systemctl restart backend &>>$LOGFILE 
VALIDATE  $? "Restarting Backend" 


