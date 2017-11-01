#!/bin/bash

###mysqlのrootユーザのパスワード
ROOTPASSWORD='newpassword'
################################
#start installing MariaDB 5.5
mysql --version

if [ $? -ne 0 ]; then
  yum -y install mariadb-server #install mariadb
  systemctl start mariadb && systemctl enable mariadb
  ##mysql_secure_installation
  #実行時の質問をBashで実行
  #Change the root password [Y/n]
  /usr/bin/mysqladmin drop test -f #Remove anonymous users? [Y/n]
  /usr/bin/mysql -e "delete from user where user = '';" -D mysql #Disallow root login remotely? [Y/n]
  /usr/bin/mysql -e "delete from user where user = 'root' and host = \'#{node[:hostname]}\';" -D mysql #Remove test database and access to it? [Y/n]
  /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD(ROOTPASSWORD);" -D mysql #Set root password? [Y/n] y
  /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD(ROOTPASSWORD);" -D mysql #Set root password? [Y/n] y
  /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD(ROOTPASSWORD);" -D mysql #Set root password? [Y/n] y
  /usr/bin/mysqladmin flush-privileges -p ROOTPASSWORD #Reload privilege tables now? [Y/n] y
  if [ $? -eq 0 ]; then
    cp -p /etc/my.cnf /etc/my.cnf.org
    sed -i "2s/^/character-set-server=utf8/g" /etc/my.cnf
  else
    echo "Failed to install mariadb."
  fi
else
  echo "Already installed mariadb."
fi

firewall-cmd --list-all | grep mariadb
if [ $? -eq 1 ]; then
  firewall-cmd --add-service=mysql --permanent && firewall-cmd --reload
else
  echo "Already set mariadb in firewalld."
fi
