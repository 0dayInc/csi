#!/bin/bash --login
sudo apt-get install -y linux-headers-$(uname -r)
sudo apt-get install --reinstall -y open-vm-tools-desktop
