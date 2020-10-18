CREATE USER 'haproxy'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'haproxy'@'%';

CREATE USER 'app'@'%' IDENTIFIED BY 'pwd';
GRANT ALL PRIVILEGES ON *.* TO 'app'@'%';
