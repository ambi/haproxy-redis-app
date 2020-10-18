#!/bin/sh

master_host=mysql1
root_password=pwd

while ! mysqladmin ping -h ${master_host} --silent; do
  sleep 1
done

mysql -u root --password="${root_password}" -h ${master_host} -e "RESET MASTER;"
mysql -u root --password="${root_password}" -h ${master_host} -e "FLUSH TABLES WITH READ LOCK;"

mysqldump -uroot --password="${root_password}" -h ${master_host} --all-databases --master-data --single-transaction --flush-logs --events > /tmp/master_dump.sql

mysql -u root --password="${root_password}" -e "STOP SLAVE;";
mysql -u root --password="${root_password}" < /tmp/master_dump.sql

log_file=`mysql -u root --password="${root_password}" -h ${master_host} -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql -u root --password="${root_password}" -h ${master_host} -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`

mysql -u root --password="${root_password}" -e "RESET SLAVE";
mysql -u root --password="${root_password}" -e "CHANGE MASTER TO MASTER_HOST='${master_host}', MASTER_USER='root', MASTER_PASSWORD='${root_password}', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
mysql -u root --password="${root_password}" -e "start slave"

mysql -u root --password="${root_password}" -h ${master_host} -e "UNLOCK TABLES;"
