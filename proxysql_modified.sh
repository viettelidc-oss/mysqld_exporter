#!/bin/bash

QUERY="select \"INSERT INTO mysql_users (username,password,default_hostgroup) VALUES (\", CONCAT(\"'\",User,\"'\"), \",\", CONCAT(\"'\",Password,\"'\"), \",0);\" from mysql.user WHERE Password LIKE \"*%\" order by User;"

if [ ! -f "/home/trove/.guestagent.prepare.end" ]; then
    echo "Ignore ..."
elif [[ -f "/home/trove/.proxy.end" && -f "/home/trove/.guestagent.prepare.end" ]]; then
    QUERY="select \"INSERT INTO mysql_users (username,password,default_hostgroup) VALUES (\", CONCAT(\"'\",User,\"'\"), \",\", CONCAT(\"'\",Password,\"'\"), \",0);\" from mysql.user WHERE Password LIKE \"*%\" order by User;"

    mysql -uadmin -padmin -P 6032 -e "delete from mysql_users;"
    mysql -B -s -P 9999 -e "$QUERY" | while read line ; do mysql -uadmin -padmin -P 6032 -e "$line"; done
    mysql -uadmin -padmin -P 6032 -e "LOAD MYSQL USERS TO RUNTIME;"
    #mysql -P 6032 -e "SAVE MYSQL USERS TO DISK" -- No need to save to disk since we sync every 5s
elif [[ ! -f "/home/trove/.proxy.end" && -f "/home/trove/.guestagent.prepare.end" ]]; then
    sed '10s/3306/9999/' /etc/mysql/my.cnf >> /etc/mysql/my.cnf
    systemctl restart mariadb.service
    /bin/bash /etc/proxysql_setup.sh
else
    echo "Ignore ...."
fi
