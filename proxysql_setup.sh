#!/bin/bash

while [ ! -f "/home/trove/.guestagent.prepare.end" ]; do

sleep 60

done

sed 's/port = 3306/port = 9999/' /etc/mysql/my.cnf >> /home/trove/my_bak.cnf && sudo mv /home/trove/my_bak.cnf /etc/mysql/my.cnf
sudo systemctl restart mariadb.service
sudo systemctl restart mysql

if [ `grep "^port = 9999" /home/trove/.my.cnf | wc -l` == 0 ]; then
sudo echo "port = 9999" >> /home/trove/.my.cnf;
fi

sudo dpkg -i /etc/proxysql_modified.deb

sudo service proxysql restart
sleep 60

sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_servers(hostgroup_id,hostname,port) VALUES (0,'127.0.0.1',9999);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "LOAD MYSQL SERVERS TO RUN;"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "SAVE MYSQL SERVERS TO DISK;"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,apply) VALUES (100,1,'os_admin','.',1);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_query_rules (rule_id,active,username,schemaname,match_digest,apply) VALUES (200,1,'os_admin','mysql','.',1);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_query_rules (rule_id,active,match_digest,error_msg,apply) VALUES (1000,1,'^[(select)|(insert)|(update)|(delete)|(create)|(drop)|(truncate)|(backup)|(reload)|(process)|(references)|(index)|(alter)|(show databases)|(create temporary tables)|(lock tables)|(execute)|(replication slave)|(replication client)|(create view)|(show view)|(create routine)|(alter routine)|(create user)|(event)|(trigger)].* mysql\..*','Use of system database is forbidden !',1);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_query_rules (rule_id,active,match_digest,error_msg,apply) VALUES (1100,1,'^[(drop)|(delete)|(update)|(alter)|(use)].* mysql.*','Use of system database is forbidden !',1);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "INSERT INTO mysql_query_rules (rule_id,active,schemaname,match_digest,error_msg,apply) VALUES (2000,1,'mysql','.','Use of system database is forbidden !',1);"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "LOAD MYSQL QUERY RULES TO RUN;"
sudo mysql -uadmin -padmin -P 6032 -h 127.0.0.1 -e "SAVE MYSQL QUERY RULES TO DISK;"

#Setup cron task
echo "* * * * * /etc/proxysql_modified.sh" >> /etc/proxysqlcron
/usr/bin/crontab /etc/proxysqlcron

sed 's/127.0.0.1:3306/127.0.0.1:9999/' /opt/guest-agent-venv/lib/python3.5/site-packages/trove/guestagent/datastore/mysql_common/service.py >> /home/trove/service.py && sudo mv /home/trove/service.py /opt/guest-agent-venv/lib/python3.5/site-packages/trove/guestagent/datastore/mysql_common/service.py
sed 's/127.0.0.1:3306/127.0.0.1:9999/' /opt/guest-agent-venv/lib/python3.6/site-packages/trove/guestagent/datastore/mysql_common/service.py >> /home/trove/service.py && sudo mv /home/trove/service.py /opt/guest-agent-venv/lib/python3.6/site-packages/trove/guestagent/datastore/mysql_common/service.py
sed 's/127.0.0.1:3306/127.0.0.1:9999/' /opt/guest-agent-venv/lib/python3/site-packages/trove/guestagent/datastore/mysql_common/service.py >> /home/trove/service.py && sudo mv /home/trove/service.py /opt/guest-agent-venv/lib/python3/site-packages/trove/guestagent/datastore/mysql_common/service.py
sed 's/127.0.0.1:3306/127.0.0.1:9999/' /opt/guest-agent-venv/lib/python2.7/site-packages/trove/guestagent/datastore/mysql_common/service.py >> /home/trove/service.py && sudo mv /home/trove/service.py /opt/guest-agent-venv/lib/python2.7/site-packages/trove/guestagent/datastore/mysql_common/service.py
sudo systemctl restart guest-agent.service
sudo systemctl restart mysql-exporter.service

touch /home/trove/.proxySQL.done
