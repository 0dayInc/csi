#!/bin/bash --login
if [[ ! -d '/home/csiadmin/.ssh' ]]; then
  sudo mkdir -p /home/csiadmin/.ssh
  sudo chmod 0700 /home/csiadmin/.ssh
  sudo touch /home/csiadmin/.ssh/authorized_keys
  sudo chmod 0600 /home/csiadmin/.ssh/authorized_keys
  sudo chown -R csiadmin:csiadmin /home/csiadmin/.ssh
fi

sudo /bin/bash --login -c 'wget --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O ->> /home/csiadmin/.ssh/authorized_keys'
