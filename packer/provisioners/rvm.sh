#!/bin/bash --login
printf "Installing RVM ************************************************************************"
sudo apt-get install -y gnupg2
curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -

# Multi-user install required due to the need to run MSFRPCD as root w/in metasploit gemset
curl -sSL https://get.rvm.io | sudo bash -s latest
