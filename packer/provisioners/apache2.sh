#!/bin/bash --login
csi_provider=`echo $CSI_PROVIDER`

sudo apt install -y apache2
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
# Disable Version Headers
sudo /bin/bash --login -c 'echo -e "ServerSignature Off\nServerTokens Prod" >> /etc/apache2/apache2.conf'
sudo /bin/bash --login -c "cp /csi/userland/${csi_provider}/etc/apache2/*.conf /etc/apache2/sites-available/"
