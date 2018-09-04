#!/bin/bash --login
# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less

# This is a temporary fix to support arachni scanning
# until it can be addressed in https://github.com/Arachni/arachni/issues/1011

grok_error() {
  while true; do
    # Wait until screen exits session
    sudo screen -ls | grep update_os
    if [[ $? == 1 ]]; then
      grep -i -e error -e exception screenlog.*
      if [[ $? == 0 ]]; then
        echo 'Errors encountered in screenlog for update_os session!!!'
        cat screenlog.*
        exit 1
      else
        break 
      fi
    else
      printf '.'
      sleep 30
    fi
  done
}

screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'

# pin openssl for arachni proxy plugin Arachni/arachni#1011
update_os_recipe=(
  'echo -e "Package: openssl\nPin: version 1.1.0*\nPin-Priority: 1001" > /etc/apt/preferences.d/openssl'
  "apt update"
  "apt install -y debconf-utils"
  "echo 'samba-common samba-common/dhcp boolean false' | debconf-set-selections"
  "echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections"
  "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | debconf-set-selection"
  "echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | debconf-set-selections"
  "echo 'wireshark-common wireshark-common/install-setuid boolean false' | debconf-set-selections"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade -y"
  "apt autoremove -y"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -y apt-file"
  "apt-file update"
  "apt install -y kali-linux-all"
)

# Update OS per update_os_recipe function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.
for instruction in ${update_os_recipe[@]} ; do
  $screen_cmd $instruction
grok_error
done
