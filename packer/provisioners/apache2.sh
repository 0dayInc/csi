#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  csi_root='/csi'
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`

sudo apt install -y apache2
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
# Disable Version Headers
sudo /bin/bash --login -c 'echo -e "ServerSignature Off\nServerTokens Prod" >> /etc/apache2/apache2.conf'
sudo /bin/bash --login -c "cp ${csi_root}/etc/userland/${csi_provider}/apache2/*.conf /etc/apache2/sites-available/"
