#!/bin/bash --login
source /etc/profile.d/globals.sh

if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`

$screen_cmd "${apt} install -y apache2 ${assess_update_errors}"
$screen_cmd "a2enmod proxy ${assess_update_errors}"
$screen_cmd "a2enmod proxy_http ${assess_update_errors}"
$screen_cmd "a2enmod rewrite ${assess_update_errors}"
$screen_cmd "a2enmod ssl ${assess_update_errors}"
$screen_cmd "a2enmod headers ${assess_update_errors}"
# Disable Version Headers
$screen_cmd "echo -e \"ServerSignature Off\nServerTokens Prod\" >> /etc/apache2/apache2.conf ${assess_update_errors}"
$screen_cmd "cp ${csi_root}/etc/userland/${csi_provider}/apache2/*.conf /etc/apache2/sites-available/ ${assess_update_errors}"
