#!/bin/bash
csi_admin_user='csi_admin'
ssh_path="/home/${csi_admin_user}/.ssh"

sudo useradd -m $csi_admin_user -s /bin/bash
sudo chmod 0700 /home/$csi_admin_user

  sudo mkdir -p $ssh_path
  sudo chmod 0700 $ssh_path
  sudo touch $ssh_path/authorized_keys
  sudo chmod 0600 $ssh_path/authorized_keys
  sudo chown -R csi_admin:csi_admin $ssh_path

sudo usermod -aG sudo $csi_admin_user
sudo /bin/bash --login -c "echo '${csi_admin_user}   ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo /bin/bash --login -c "cat /home/ec2-user/.ssh/authorized_keys > ${ssh_path}/authorized_keys && chown -R ${csi_admin_user}:${csi_admin_user} ${ssh_path}/authorized_keys"
