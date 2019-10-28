#!/bin/bash --login
for user in csiadmin admin; do
  if [[ ! -d "/home/${user}/.ssh" ]]; then
    sudo mkdir -p /home/$user/.ssh
    sudo chmod 0700 /home/$user/.ssh
    sudo touch /home/$user/.ssh/authorized_keys
    sudo chmod 0600 /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user/.ssh
  fi

  sudo /bin/bash --login -c "wget --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O ->> /home/${user}/.ssh/authorized_keys"
done
