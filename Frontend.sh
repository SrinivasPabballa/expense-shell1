#!/bin/bash

USERID=$( id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$TIMESTAMP-$SCRIPTNAME.log

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
 
dnf install nginx -y &>>$LOGFILE 
VALIDATE $? "Installing nginx"

systemctl enable nginx  &>>$LOGFILE 
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE 
VALIDATE $? "Starting nginx" 

rm -rf /usr/share/nginx/html/* &>>$LOGFILE 
VALIDATE $? "Removing the default content" 

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE 
VALIDATE $? "Downloading the Frontend Content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE 
VALIDATE $? "Unzipping the frontend content" 
 
 cp /home/ec2-user/expense-shell1/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE 
VALIDATE $? "copyying expense path"

systemctl restart nginx  &>>$LOGFILE 
VALIDATE $? "Restarting Nginx"

