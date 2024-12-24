#!/bin/bash

#user check 
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"


ID=$(id -u)

if [ $ID -ne 0 ]
then 
    echo "switch to the root user"
    exit 1
else
    echo "root user"
fi

VALIDATE ()
{
    if [ $1 -ne 0 ]
    then 
        echo "$2...is failed"
    else
        echo "$2.. is success"
    fi
}



dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting mysql server user and password"