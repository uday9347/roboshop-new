#!/bin/bash

#user check 
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"
MONGOIP=172.31.18.255


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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> LOGFILE
VALIDATE $? "installing the zip file"

cd /app &>> LOGFILE
VALIDATE $? "redirecting to the  the app directory"

unzip -o /tmp/user.zip  &>> LOGFILE
VALIDATE $? "unzipping the files in the app directory"

cd /app &>> LOGFILE
VALIDATE $? "redirecting to the  the app directory"

npm install &>> LOGFILE
VALIDATE $? "installing the dependencies"

cp /home/ec2-user/roboshop-new/user/user.service /etc/systemd/system/user.service  &>> LOGFILE
VALIDATE $? "copying the files to sytemd "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading the service"

systemctl enable user &>> $LOGFILE
VALIDATE $? "enabling the service"

systemctl start user &>> $LOGFILE
VALIDATE $? "starting the service"


cp  /home/ec2-user/roboshop-new/catalogue/mongo.repo /etc/yum.repos.d &>> $LOGFILE
VALIDATE $? "creating mongo repo"

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "installing mongodb shell"

echo "$MONGOIP"
mongosh --host  $MONGOIP </app/schema/user.js &>> $LOGFILE
VALIDATE  $? "loading catalogue data in mongodb"