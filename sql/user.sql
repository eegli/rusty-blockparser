CREATE USER 'usr'@'%' IDENTIFIED BY 'pw';
GRANT ALL PRIVILEGES ON *.* TO 'usr'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;