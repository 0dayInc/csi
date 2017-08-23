#!/bin/bash --login
sudo apt-get purge -y virtualbox-*
sudo apt-get install -y linux-headers-$(uname -r)
sudo apt-get install -y virtualbox-guest-x11
