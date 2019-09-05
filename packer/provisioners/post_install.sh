#!/bin/bash --login
csi_provider=`echo $CSI_PROVIDER`

# Clenup History
sudo /bin/bash --login -c 'find /home -type f -name ".*history" -exec shred -u {} \;'
sudo /bin/bash --login -c 'find /root -type f -name ".*history" -exec shred -u {} \;'

# Disable Local Root Access
sudo passwd -l root

# Remove csiadmin account if it exists
id -u csiadmin
if [[ $? == 0 ]]; then
  sudo unshare --user --map-root-user userdel -f csiadmin
fi

# Remove SSH Host Key Pairs
sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

if [[ $csi_provider == 'aws' ]]; then
  debconf_set='/usr/bin/debconf-set-selections'
  sudo /bin/bash --login -c "echo 'grub-installer grub-installer/only_debian boolean true' | ${debconf_set}"
  sudo /bin/bash --login -c "echo 'grub-installer grub-installer/with_other_os boolean true' | ${debconf_set}"
  sudo /bin/bash --login -c "echo 'grub-pc grub-pc/install_devices multiselect /dev/xvda' | ${debconf_set}"
  sudo /bin/bash --login -c "DEBIAN_FRONTEND=noninteractive apt install -yq xfsprogs debootstrap euca2ools dhcpcd5 cloud-init spin && update-grub2 && update-initramfs -u"

  sudo /bin/bash --login -c 'find /home -type d -name "authorized_keys" -exec shred -u {} \;'
else
  # Remove Packer SSH Key from authorized_keys file
  sudo sed -i '/packer/d' /home/admin/.ssh/authorized_keys
fi
