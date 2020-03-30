#!/bin/bash

#wget -P /etc/ https://github.com/viettelidc-oss/mysqld_exporter/raw/master/proxysql_modified.deb
#chmod 777 /etc/proxysql_modified.deb
dpkg -i /etc/proxysql_modified.deb

#Restart to change port
service proxysql restart

#Need to change MariaDB / MySQL server's port to 9999
#Add backend SQL server
mysql -uadmin -padmin -P 6032 -e "INSERT INTO mysql_servers(hostgroup_id,hostname,port) VALUES (0,'127.0.0.1',9999);"
mysql -uadmin -padmin -P 6032 -e "LOAD MYSQL SERVERS TO RUN;"
mysql -uadmin -padmin -P 6032 -e "SAVE MYSQL SERVERS TO DISK;"

#Insert DBFirewall rule
mysql -uadmin -padmin -P 6032 -e "INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,apply) VALUES (100,1,'os_admin','.',1);"
mysql -uadmin -padmin -P 6032 -e "INSERT INTO mysql_query_rules (rule_id,active,username,schemaname,match_digest,apply) VALUES (200,1,'os_admin','mysql','.',1);"
mysql -uadmin -padmin -P 6032 -e "INSERT INTO mysql_query_rules (rule_id,active,match_digest,error_msg,apply) VALUES (1000,1,'^[(select)|(insert)|(update)|(delete)|(create)|(drop)|(reload)|(process)|(references)|(index)|(alter)|(show databases)|(create temporary tables)|(lock tables)|(execute)|(replication slave)|(replication client)|(create view)|(show view)|(create routine)|(alter routine)|(create user)|(event)|(trigger)].* mysql\..*','Use of system database is forbidden !',1);"
mysql -uadmin -padmin -P 6032 -e "INSERT INTO mysql_query_rules (rule_id,active,schemaname,match_digest,error_msg,apply) VALUES (2000,1,'mysql','.','Use of system database is forbidden !',1);"
mysql -uadmin -padmin -P 6032 -e "LOAD MYSQL QUERY RULES TO RUN;"
mysql -uadmin -padmin -P 6032 -e "SAVE MYSQL QUERY RULES TO DISK;"

#Setup cron task
#echo "* * * * * /etc/proxysql_modified.sh" >> /etc/proxysqlcron
#/usr/bin/crontab /etc/proxysqlcron

touch /home/trove/.proxy.end
