#!/bin/bash --login
mkdir -p /home/csiadmin/.ssh
chmod 0700 /home/csiadmin/.ssh
wget \
  --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
  -O /home/csiadmin/.ssh/authorized_keys
chmod 0600 /home/csiadmin/.ssh/authorized_keys
chown -R csiadmin:csiadmin /home/csiadmin/.ssh
