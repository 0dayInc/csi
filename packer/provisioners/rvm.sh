#!/bin/bash --login
os=$(uname -s)

case $os in
  'Darwin')
    sudo port -N install gnupg2
    ;;
  'Linux')
    sudo apt-get install -y gnupg2
    ;;
  *)
    echo "${os} not currently supported."
    exit 1
esac

curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
sudo /bin/bash --login -c 'echo -e "trust\n5\ny\n" | gpg2 --command-fd 0 --edit-key 409B6B1796C275462A1703113804BB82D39DC0E3'

# Multi-user install required due to the need to run MSFRPCD as root w/in metasploit gemset
curl -sSL https://get.rvm.io | sudo bash -s latest
