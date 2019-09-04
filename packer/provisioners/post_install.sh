#!/bin/bash --login
csi_golden_image=`echo $CSI_GOLDEN_IMAGE`

# Clenup History
shred -u ~/.*history
sudo shred -u /root/.*history

# Disable Local Root Access
sudo passwd -l root

# Remove csiadmin account if it exists
id -u csiadmin
if [[ $? == 0 ]]; then
  sudo userdel -f csiadmin
fi

# Remove SSH Host Key Pairs
sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

if [[ $csi_golden_image == 'aws_ami' ]]; then
  debconf_set='/usr/bin/debconf-set-selections'
  sudo /bin/bash --login -c "echo 'grub-installer grub-installer/only_debian boolean true' | ${debconf_set}"
  sudo /bin/bash --login -c "echo 'grub-installer grub-installer/with_other_os boolean true' | ${debconf_set}"
  sudo /bin/bash --login -c "echo 'grub-pc grub-pc/install_devices multiselect /dev/xvda' | ${debconf_set}"
  sudo /bin/bash --login -c "DEBIAN_FRONTEND=noninteractive apt install -yq xfsprogs debootstrap euca2ools dhcpcd5 cloud-init spin && update-grub2 && update-initramfs -u"

  if [[ -e /home/admin/.ssh/authorized_keys ]]; then
    sudo rm /home/admin/.ssh/authorized_keys
  fi
else
  # Remove Packer SSH Key from authorized_keys file
  sudo sed -i '/packer/d' /home/admin/.ssh/authorized_keys
fi
