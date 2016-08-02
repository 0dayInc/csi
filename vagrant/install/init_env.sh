#!/bin/bash
hostname=$1
echo "Updating FQDN: ${hostname}"
cat /etc/hosts | grep "${hostname}" || sudo sed "s/127.0.0.1/127.0.0.1 ${hostname}/g" -i /etc/hosts
hostname | grep "${hostname}" || sudo hostname "${hostname}"
sudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers
sudo echo 'Defaults:ubuntu !requiretty' >> /etc/sudoers
