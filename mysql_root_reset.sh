#!/bin/bash

systemctl stop mysql
mysqld_safe --skip-grant-tables >res 2>&1 &
sleep 5
mysql -uroot -e "flush privileges;ALTER USER 'root'@'localhost' IDENTIFIED by '';"
mysqladmin shutdown
#killall -v mysqld
systemctl start mysql
