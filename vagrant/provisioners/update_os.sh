#!/bin/bash --login
# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less
sudo screen -L -S update_os -d -m /bin/bash --login -c "apt update && echo 'samba-common samba-common/dhcp boolean false' | debconf-set-selections && echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections && echo 'console-setup console-setup/codeset47 select Guess optimal character set' | debconf-set-selections && echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | debconf-set-selections && echo 'wireshark-common wireshark-common/install-setuid boolean false' | debconf-set-selections && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade -y && apt autoremove -y && apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -y apt-file && apt-file update"

while true; do
  # Wait until screen exits session
  sudo screen -ls | grep update_os
  if [[ $? == 1 ]]; then
    # TODO: grok screenlog.0 to ensure we should be exiting w/ 0 & not 1
    grep -i -e error -e exception screenlog.*
    if [[ $? == 0 ]]; then
      echo 'Errors encountered in screenlog for update_os session!!!'
      cat screenlog.*
      exit 1
    else
      exit 0
    fi
  else
    printf '.'
    sleep 30
  fi
done
