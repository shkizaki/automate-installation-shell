#!/bin/bash
#################################
##install Apache and firewalld"##
#################################
#temporary disabled SELinux
setenforce 0
#install firewalld
firewall-cmd --version
if [ $? -ne 0 ]; then
  yum -y install firewalld
  if [ $? -eq 0 ]; then
    systemctl enable firewalld && systemctl start firewalld
    if [ $? -eq 0 ]; then
      firewall-cmd --add-service=http --permanent && firewall-cmd --reload
    else
      echo "Failed to start firewalld."
    fi
  else
    echo "Failed to install firewalld."
  fi
else
  echo "Already installed firewalld."
fi

#install httpd
httpd -V
if [ $? -ne 0 ]; then
  yum -y install httpd
  if [ $? -eq 0 ]; then
    systemctl enable httpd && systemctl start httpd
    if [ $? -eq 0 ]; then
      ######################
      ##modify config file##
      ######################
      #backup httpd.conf
      cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.org
      #modify FQDN
      sed -i -e "s/#ServerName www.example.com:80/ServerName `hostname`/" /etc/httpd/conf/httpd.conf
      #modify enable load ./htaccess
      sed -i -e "s/AllowOverride None/AllowOverride ALL/" /etc/httpd/conf/httpd.conf
      #add keep connection
      echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
      echo "KeepAlive On" >> /etc/httpd/conf/httpd.conf
      systemctl reload httpd
    else
      echo "Failed to start httpd."
    fi
  else
    echo "Failed to install httpd."
  fi
else
  echo "Already installed httpd."
fi

systemctl status httpd
if [ $? -eq 3 ]; then
  systemctl start httpd
fi
