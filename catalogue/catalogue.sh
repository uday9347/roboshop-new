#!/bin/bash

#user check 
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"
MONGOIP=172.31.90.238

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "the appliaction downlaoding in the tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "switching into app directory"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziping in the environment"

npm install &>> $LOGFILE
VALIDATE $? "Installing the dependencies"

cp /home/ec2-user/roboshop-new/catalogue/catalogue.service /etc/systemd/system/  &>> $LOGFILE
VALIDATE $? "craeting the catalogue service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the service"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enabling the service"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting the service"

cp  /home/ec2-user/roboshop-new/catalogue/mongo.repo /etc/yum.repos.d &>> $LOGFILE
VALIDATE $? "creating mongo repo"

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "installing mongodb shell"


mongosh --host $MONGOIP </app/schema/catalogue.js &>> $LOGFILE
VALIDATE  $? "loading catalogue data in mongodb"