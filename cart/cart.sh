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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling the nodejs current version"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "enabling the nodejs current version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing the current nodejs version"

id roboshop &>> $LOGFILE

if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "useradd user creation "
else 
    echo "user creation skipping"
fi 

mkdir -p /app &>> $LOGFILE
VALIDATE $? "the app directory creation"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "installing the cart zip files in tmp"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzipping the files"

cd /app 

npm install &>> $LOGFILE
VALIDATE $? "installing the dependencies"


cp /home/ec2-user/roboshop-new/cart/cart.service /etc/systemd/system/  &>> $LOGFILE
VALIDATE $? "craeting the cart service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"


systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling cart"


systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"
