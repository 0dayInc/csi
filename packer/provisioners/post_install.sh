#!/bin/bash --login
pinned_kernel_file='/etc/apt/preferences.d/linux-image-amd64'

# Change password at first login
sudo passwd --expire csiadmin

# Remove Packer SSH Key from authorized_keys file
sudo sed -i '/packer/d' /home/csiadmin/.ssh/authorized_keys

# Removed pinned kernel from AWS AMIs
if [[ -f $pinned_kernel_file ]]; then
  sudo rm $pinned_kernel_file
fi
