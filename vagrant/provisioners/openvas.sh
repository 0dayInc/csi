#!/bin/bash
# Update user/pass based on UserLand Configs
csi_provider=`echo $CSI_PROVIDER`
user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/userland/${csi_provider}/openvas/vagrant.yaml')['user']"`
pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/userland/${csi_provider}/openvas/vagrant.yaml')['pass']"`
fqdn=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/userland/${csi_provider}/apache2/vagrant.yaml')['common_name_fqdn']"`
sudo /bin/bash --login -c "openvasmd --create-user ${user}"
sudo /bin/bash --login -c "openvasmd --user=${user} --new-password=${pass}"
sudo sed -i "9s/.*/ExecStart=\/usr\/sbin\/gsad --foreground --listen=127\.0\.0\.1 --port=9392 --mlisten=127\.0\.0\.1 --mport=9390 --http-only --no-redirect --allow-header-host openvas.${fqdn}/" /lib/systemd/system/greenbone-security-assistant.service
sudo systemctl daemon-reload
sudo systemctl restart greenbone-security-assistant
