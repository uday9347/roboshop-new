#!/bin/bash

#user check 
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"
exec &>$LOGFILE


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

dnf install redis -y
VALIDATE $? "installing redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf 
VALIDATE $? "changing the ip in the redis"

systemctl enable redis
VALIDATE $? "enabling redis"

systemctl start redis
VALIDATE $? "starting redis"