#!/bin/bash

date=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$?-$date.log"
ID=$(id -u )
if [ ID -ne  0 ]
then 
    echo "swicth to the root user"
else    
    echo "root user"
fi 

VALIDATE()
{
    if [ $1 -ne 0 ]
    then 
        echo "$2 is failed"
    else
        echo "$2.. is success"
    fi
}


dnf install nginx -y  &>> $LOGFILE
VALIDATE $? "installing nginx version"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx version"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx version"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing the default nginx components"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "installing web"

cd /usr/share/nginx/html

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "installing web version"

cp /home/ec2-user/roboshop-new/web/roboshop.conf /etc/nginx/default.d  &>> $LOGFILE
VALIDATE $? "craeting the catalogue service"

systemctl restart nginx 
