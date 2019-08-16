#!/bin/bash --login
mkdir -p /home/csi_admin/.ssh
chmod 0700 /home/csi_admin/.ssh
touch /home/csi_admin/.ssh/authorized_keys
chmod 0600 /home/csi_admin/.ssh/authorized_keys
chown -R csi_admin:csi_admin /home/csi_admin/.ssh
wget \
  --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub \
  -O /home/csi_admin/.ssh/authorized_keys
