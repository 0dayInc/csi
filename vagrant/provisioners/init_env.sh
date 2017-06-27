#!/bin/bash
hostname=$1

echo 'Updating /etc/sudoers'
sudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers
sudo /bin/bash --login -c 'echo "Defaults:vagrant !requiretty" >> /etc/sudoers'
echo "Updating FQDN: ${hostname}"
cat /etc/hosts | grep "${hostname}" || sudo sed "s/127.0.0.1/127.0.0.1 ${hostname}/g" -i /etc/hosts
hostname | grep "${hostname}" || sudo hostname "${hostname}"
