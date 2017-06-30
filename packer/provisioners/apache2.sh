#!/bin/bash --login
domain_name=$(hostname -d)
sudo apt-get install -y apache2
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
# Disable Version Headers
sudo echo -e "ServerSignature Off\nServerTokens Prod" >> /etc/apache2/apache2.conf
sudo systemctl start apache2
