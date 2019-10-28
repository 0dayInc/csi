#!/bin/bash --login
csi_provider=`echo $CSI_PROVIDER`

# Clenup History
sudo /bin/bash --login -c 'find /home -type f -name ".*history" -exec shred -u {} \;'
sudo /bin/bash --login -c 'find /root -type f -name ".*history" -exec shred -u {} \;'

# Cleanup Logs
sudo /bin/bash --login -c 'find /var/log -type f -name "*.log" | while read log; do > $log; done'
sudo /bin/bash --login -c 'find /var/log -type f -name "dmesg.*" -exec rm {} \;'
sudo /bin/bash --login -c '> /var/log/debug'
sudo /bin/bash --login -c '> /var/log/dmesg'
sudo /bin/bash --login -c '> /var/log/lastlog'
sudo /bin/bash --login -c '> /var/log/messages'
sudo /bin/bash --login -c '> /var/log/syslog'
sudo /bin/bash --login -c '> /var/log/wtmp'

# Disable Local Root Access
sudo passwd -l root

if [[ $csi_provider == 'aws' ]]; then
  # Remove SSH Host Key Pairs 
  # (we need to keep the initial ones for other providers until 
  # we can re-create SSH keys via vagrant/provisioners/post_install.sh)
  sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

  sudo /bin/bash --login -c 'find /home -type f -name "authorized_keys" -exec shred -u {} \;'
  sudo /bin/bash --login -c 'apt purge -y cloud-init && apt autoremove -y --purge'
  # This allows for PacketFu::Utils.whoami? to properly fuction (Used in CSI::Plugins::Packet)
  # Socket.getifaddrs.each {|ifaddr| puts ifaddr.addr.inspect}; << return nil when teredo interface exists
  # this breaks https://github.com/packetfu/packetfu/blob/master/lib/packetfu/utils.rb#L196
  # which tries to call ifaddr.addr.ip? when ifaddr.addr == Nil
  sudo systemctl stop miredo
  sudo systemctl disable miredo
fi

# Clear Bash History
history -c

if [[ $csi_provider != 'aws' ]]; then
  # Create lame password for admin user
  echo -e "changeme\nchangeme" | sudo passwd admin

  sudo passwd --expire csiadmin
fi
