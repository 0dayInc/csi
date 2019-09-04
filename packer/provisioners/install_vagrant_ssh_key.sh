#!/bin/bash --login
if [[ ! -d '/home/admin/.ssh' ]]; then
  sudo mkdir -p /home/admin/.ssh
  sudo chmod 0700 /home/admin/.ssh
  sudo touch /home/admin/.ssh/authorized_keys
  sudo chmod 0600 /home/admin/.ssh/authorized_keys
  sudo chown -R admin:admin /home/admin/.ssh
fi

sudo /bin/bash --login -c 'wget --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O ->> /home/admin/.ssh/authorized_keys'
