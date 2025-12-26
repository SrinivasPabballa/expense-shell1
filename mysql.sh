#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$TIMESTAMP-$SCRIPT_NAME.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please Enter DB  Password:"
read -s mysql_root_password

VALIDATE() {

    if [ $1 -ne 0 ]
    then 
        echo -e "$2..$R FAILURE $N"
        exit 1
    else 
        echo -e "$2..$G SUCCESS $N"    
    fi    
}


if [ $USERID -ne 0 ]
  then
       echo "Please run with root user"
       exit 1
  else 
      echo "You are a superuser"
  fi 


  dnf install mysql-server -y &>>$LOGFILE
  VALIDATE $? "Installing MySQL" 

  systemctl enable mysqld &>>$LOGFILE
  VALIDATE $? "Enabling MySql" 

  systemctl start mysqld &>>$LOGFILE 
  VALIDATE $? "Starting MySql"

  mysql -h 172.31.21.21 -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
   if [ $? -eq 0 ]
    then 
         mysql_secure_installation --set-root-pass ${mysql_root_password}  &>>$LOGFILE 
         VALIDATE  $? "SettingUp Root Password"
         exit 1
    else 
         echo -e "MySql Root Password is already setup..$Y SKIPPING $N" 
    fi          
