#!/bin/bash --login
# Get Latest Updates
sudo apt update

# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less
sudo /bin/bash --login -c "echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | debconf-set-selections && echo 'wireshark-common wireshark-common/install-setuid boolean false' | debconf-set-selections && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade -y && apt autoremove -y && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -y apt-file && apt-file update"
