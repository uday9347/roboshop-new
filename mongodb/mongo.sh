#!/bin/bash


#user check 
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"

ID =$(id -u)
echo "$ID"

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
        echo "$2...failed"
    else
        echo "$2..success"
    fi
}

cp mongo.repo /etc/yum.repos.d &>> $LOGFILE
VALIDATE $? "copying the mongodb"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling mongodb" 

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongodb" 

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf  &>> $LOGFILE
VALIDATE $? "navigating the mongodb" 

systemctl restart mongod
VALIDATE $? "restarting the mongodb" &>> $LOGFILE 
