#!/bin/bash

QUERY="select \"INSERT INTO mysql_users (username,password,default_hostgroup) VALUES (\", CONCAT(\"'\",User,\"'\"), \",\", CONCAT(\"'\",Password,\"'\"), \",0);\" from mysql.user WHERE Password LIKE \"*%\" order by User;"

PROXY="select username,password from mysql_users WHERE password LIKE \"*%\" order by username;"
MYSQL="select user as username,password from mysql.user WHERE password LIKE \"*%\" order by user;"

i=0

while [ $i -lt 12 ]; do # 1 min cron job has 12 turns each has 5s sleep

#compare proxysql user list and mysql user list:
MYSQL_USER=`mysql -B -s -P 9999 -uos_admin -pQ4dpVfj1s7ObjP81PzsBdnT1GSRIMurt6ab8 -h 127.0.0.1 -e "$MYSQL"`
PROXY_USER=`mysql -B -s -uadmin -padmin -h 127.0.0.1 -P 6032 -e "$PROXY"` # without -h it'll called to -h localhost => to MySQL

if [ "$MYSQL_USER" == "$PROXY_USER" ]
then
sleep 5
i=$(( i + 1 ))
else
mysql -uadmin -padmin -h 127.0.0.1 -P 6032 -e "delete from mysql_users;"
mysql -B -s -uos_admin -pQ4dpVfj1s7ObjP81PzsBdnT1GSRIMurt6ab8 -h 127.0.0.1 -P 9999 -e "$QUERY" | while read line ; do mysql -uadmin -padmin -h 127.0.0.1 -P 6032 -e "$line"; done
mysql -uadmin -padmin -h 127.0.0.1 -P 6032 -e "LOAD MYSQL USERS TO RUNTIME;"
sleep 5
i=$(( i + 1 ))
fi
done
