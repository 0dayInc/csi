#!/bin/bash
hostname=`hostname`
csi_admin_user='csi_admin'

sudo useradd -m $csi_admin_user
sudo usermod -aG sudo $csi_admin_user
echo "Updating FQDN: ${hostname}"
cat /etc/hosts | grep "${hostname}"
sudo sed "s/127.0.0.1/127.0.0.1 ${hostname}/g" -i /etc/hosts
sudo chmod 660 /etc/sudoers
sudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers
sudo echo 'Defaults:csi_admin !requiretty' >> /etc/sudoers
sudo chmod 440 /etc/sudoers
sudo userdel ec2-user
