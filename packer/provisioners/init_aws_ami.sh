#!/bin/bash
hostname=`hostname`
csi_admin_user='csi_admin'

sudo useradd -m $csi_admin_user
sudo chmod 700 /home/$csi_admin_user
sudo usermod -aG sudo $csi_admin_user
sudo /bin/bash --login -c "echo '${csi_admin_user}   ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
