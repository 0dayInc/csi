#!/bin/bash --login
sudo apt purge -y virtualbox-*
sudo apt install -y linux-headers-$(uname -r)
sudo apt install -y virtualbox-guest-x11
