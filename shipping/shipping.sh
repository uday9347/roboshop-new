#!/bin/bash

#user check 
TIME=$(date +%F-%H-%M-%S)
USER=root 
PASS=RoboShop@1

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



dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

id roboshop &>> $LOGFILE

if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "useradd user creation "
else 
    echo "user creation skipping"
fi 


mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "insatlling zip "

cd /app  &>> $LOGFILE
VALIDATE $? "changing dir"

unzip -0 /tmp/shipping.zip  &>> $LOGFILE


cd /app  &>> $LOGFILE
VALIDATE $? "changing dir"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependencies "

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "changing name "

cp /home/ec2-user/roboshop-new/shipping/shipping.service /etc/systemd/system/shipping.service &>> LOGFILE
VALIDATE $? "copying the service file to location"

systemctl daemon-reload

systemctl enable shipping 

systemctl start shipping

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing sql "

mysql -h 172.31.21.180 -u$USER -p$PASS< /app/db/schema.sql

mysql -h 172.31.21.180 -u$USER -p$PASS< /app/db/app-user.sql 

mysql -h 172.31.21.180  -u$USER -p$PASS < /app/db/master-data.sql &>> $LOGFILE
VALIDATE $? "added schema to db "

systemctl restart shipping