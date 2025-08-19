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

    if [ $1-ne 0 ]
    then 
        echo -e "$2..$R FAILURE $N "
    else 
        echo "$2..$G SUCCESS $N" 
   fi      
}       



