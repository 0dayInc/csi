#!/bin/bash --login
# Get Latest Updates
sudo apt-get update

# Install Dependency to Automate Package Install Questions
sudo apt-get install -y debconf-utils

# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less
echo "wireshark-common wireshark-common/install-setuid boolean false" | debconf-set-selections

# Install Latest Updates
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade -y
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade -y
sudo apt autoremove -y
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y apt-file
sudo apt-file update
