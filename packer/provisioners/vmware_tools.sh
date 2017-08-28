#!/bin/bash --login
sudo apt install -y linux-headers-$(uname -r)
sudo apt install --reinstall -y open-vm-tools-desktop
