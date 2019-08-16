#!/bin/bash --login
sudo mkdir -p /home/csi_admin/.ssh
sudo chmod 0700 /home/csi_admin/.ssh
sudo touch /home/csi_admin/.ssh/authorized_keys
sudo chmod 0600 /home/csi_admin/.ssh/authorized_keys
sudo chown -R csi_admin:csi_admin /home/csi_admin/.ssh
sudo wget \
  --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub \
  -O /home/csi_admin/.ssh/authorized_keys
