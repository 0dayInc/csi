#!/bin/bash --login
csi_provider=`echo $CSI_PROVIDER`

# Clenup History
sudo /bin/bash --login -c 'find /home -type f -name ".*history" -exec shred -u {} \;'
sudo /bin/bash --login -c 'find /root -type f -name ".*history" -exec shred -u {} \;'

# Cleanup Logs
sudo /bin/bash --login -c 'find /var/log -type f -name "*.log" -exec > {} \;'
sudo /bin/bash --login -c 'find /var/log -type f -name "dmesg.*" -exec rm {} \;'
sudo /bin/bash --login -c '> /var/log/debug'
sudo /bin/bash --login -c '> /var/log/dmesg'
sudo /bin/bash --login -c '> /var/log/lastlog'
sudo /bin/bash --login -c '> /var/log/messages'
sudo /bin/bash --login -c '> /var/log/syslog'
sudo /bin/bash --login -c '> /var/log/wtmp'

# Disable Local Root Access
sudo passwd -l root

# Remove SSH Host Key Pairs
sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

if [[ $csi_provider == 'aws' ]]; then
  sudo /bin/bash --login -c 'find /home -type d -name "authorized_keys" -exec shred -u {} \;'
fi

# Clear Bash History
sudo history -c
history -c

if [[ $csi_provider != 'aws' ]]; then
  # Remove csiadmin account if it exists
  sudo rm -rf /home/csiadmin
  sudo sed -i '/^csiadmin/d' /etc/group
  sudo sed -i 's/csiadmin//g' /etc/group
  sudo sed -i 's/:,/:/g' /etc/group
  sudo sed -i '/^csiadmin/d' /etc/shadow 
  sudo sed -i '/^csiadmin/d' /etc/passwd 

  # Create lame password for admin user
  echo 'changeme' | sudo passwd --stdin admin
fi
