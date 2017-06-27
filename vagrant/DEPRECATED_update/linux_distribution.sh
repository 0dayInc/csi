#!/bin/bash --login
domain_name=`hostname`
printf "Updating ${domain_name} w/ Latest Packages ********************************************"
# Repair "==> default: stdin: is not a tty" message
#sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile
#sudo /bin/bash --login -c "sudo cat /dev/null > /etc/issue && sudo cat /dev/null > /etc/issue.net"
# TODO: create an ARGV that allows for condition to decide if config overwriting should be ignored (i.e. Vagrant)
# or
# overwritten (i.e. os updates w/in Jenkins builds) 
sudo apt-get update
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade -y
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade -y
sudo apt autoremove -y
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y apt-file
sudo apt-file update
