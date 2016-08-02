#!/bin/bash --login
printf "Installing LXDE ***********************************************************************"
sudo apt-get install -y lxde lxdm
sudo /etc/init.d/lxdm restart
