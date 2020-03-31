#!/bin/bash

QUERY="select \"INSERT INTO mysql_users (username,password,default_hostgroup) VALUES (\", CONCAT(\"'\",User,\"'\"), \",\", CONCAT(\"'\",Password,\"'\"), \",0);\" from mysql.user WHERE Password LIKE \"*%\" order by User;"
mysql -uadmin -padmin -P 6032 -e "delete from mysql_users;"
mysql -B -s -P 9999 -e "$QUERY" | while read line ; do mysql -uadmin -padmin -P 6032 -e "$line"; done
mysql -uadmin -padmin -P 6032 -e "LOAD MYSQL USERS TO RUNTIME;"
#mysql -P 6032 -e "SAVE MYSQL USERS TO DISK" -- No need to save to disk since we sync every 5s
