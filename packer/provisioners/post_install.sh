#!/bin/bash --login
# Change password at first login
sudo passwd --expire csiadmin

# Remove Packer SSH Key from authorized_keys file
sudo sed -i '/packer/d' /home/csiadmin/.ssh/authorized_keys
