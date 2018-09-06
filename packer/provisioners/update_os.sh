#!/bin/bash --login
# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less

#grok_error() {
#  while true; do
#    # Wait until screen exits session
#    sudo screen -ls | grep update_os
#    if [[ $? == 1 ]]; then
#      grep -i -e failed -e exception screenlog.*
#      if [[ $? == 0 ]]; then
#        echo 'Failures encountered in screenlog for update_os session!!!'
#        cat screenlog.*
#        exit 1
#      else
#        echo 'No errors in update detected...moving onto the next.'
#        break 
#      fi
#    else
#      printf '.'
#      sleep 30
#    fi
#  done
#}

# PINNED PACKAGES
# pin openssl for arachni proxy plugin Arachni/arachni#1011
sudo /bin/bash --login -c 'echo "Package: openssl" > /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin: version 1.1.0*" >> /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/openssl'

# Update OS per update_os_instructions function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.
screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'
assess_screen_err='|| echo "Installation failed" && exit 1'

$screen_cmd "apt update" $assess_screen_err
#grok_error

$screen_cmd "apt install -y debconf-utils" $assess_screen_err
#grok_error

$screen_cmd "echo 'samba-common samba-common/dhcp boolean false' | debconf-set-selections" $assess_screen_err
#grok_error

$screen_cmd "echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections" $assess_screen_err
#grok_error

$screen_cmd "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | debconf-set-selection" $assess_screen_err
#grok_error

$screen_cmd "echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | debconf-set-selections" $assess_screen_err
#grok_error

$screen_cmd "echo 'wireshark-common wireshark-common/install-setuid boolean false' | debconf-set-selections" $assess_screen_err
#grok_error

$screen_cmd "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y" $assess_screen_err
#grok_error

$screen_cmd "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade -y" $assess_screen_err
#grok_error

$screen_cmd "apt autoremove -y" $assess_screen_err
#grok_error

$screen_cmd "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -y apt-file" $assess_screen_err
#grok_error

$screen_cmd "apt-file update" $assess_screen_err
#grok_error

$screen_cmd "apt install -y kali-linux-all" $assess_screen_err
#grok_error

sudo rm screenlog.*
