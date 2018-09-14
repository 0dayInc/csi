#!/bin/bash --login
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
wget \
  --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
  -O /home/vagrant/.ssh/authorized_keys
