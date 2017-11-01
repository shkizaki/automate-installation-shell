#!/bin/bash
#installing php
php --version
if [ $? -ne 0 ]; then
  yum -y install php php-mbstring php-pear
  if [ $? -eq 0 ]; then
    cp -p /etc/php.ini /etc/php.ini.org
    sed -i -e 's/;date.timezone =/date.timezone = "Asia/Tokyo"/g' /etc/php.ini
    sed -i -e 's/DirectoryIndex index.html/DirectoryIndex index.html index.php/g' /etc/httpd/conf/httpd.conf
    systemctl restart httpd
    if [ $? -eq 0 ]; then
      echo "Installed php successfully."
    else
      echo "Failed to restart httpd."
    fi
  else
    echo "Failed to install php."
  fi
else
  echo "Already installed php."
fi
