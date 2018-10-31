#!/bin/bash --login
# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less

grok_error() {
  while true; do
    # Wait until screen exits session
    sudo screen -ls | grep update_os
    if [[ $? == 1 ]]; then
      grep UPDATE_ABORT screenlog.*
      if [[ $? == 0 ]]; then
        echo 'Failures encountered in screenlog for update_os session!!!'
        cat screenlog.*
        exit 1
      else
        echo 'No errors in update detected...moving onto the next.'
        break 
      fi
    else
      printf '.'
      sleep 9
    fi
  done
}

# PINNED PACKAGES
# pin openssl for arachni proxy plugin Arachni/arachni#1011
sudo /bin/bash --login -c 'echo "Package: openssl" > /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin: version 1.1.0*" >> /etc/apt/preferences.d/openssl'
sudo /bin/bash --login -c 'echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/openssl'

# Update OS per update_os_instructions function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.
screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'
assess_update_errors='|| echo UPDATE_ABORT && exit 1'
debconf_set='/usr/bin/debconf-set-selections'
apt="apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'"

# Cleanup up prior screenlog.0 file from previous update_os failure(s)
if [[ -e screenlog.0 ]]; then 
  sudo rm screenlog.0
fi

$screen_cmd "apt update ${assess_update_errors}"
grok_error

$screen_cmd "apt install -y debconf-utils ${assess_update_errors}"
grok_error

$screen_cmd "echo 'postgresql-common postgresql-common/obsolete-major boolean true' | ${debconf_set} ${assess_update_errors}"

$screen_cmd "echo 'samba-common samba-common/dhcp boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'libc6 libraries/restart-without-asking boolean true' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'wireshark-common wireshark-common/install-setuid boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "${apt} dist-upgrade -y ${assess_update_errors}"
grok_error

$screen_cmd "${apt} full-upgrade -y ${assess_update_errors}"
grok_error

$screen_cmd "${apt} autoremove -y ${assess_update_errors}"
grok_error

uname -a | grep kali
if [[ $? == 0 ]]; then
  #$screen_cmd "${apt} install -y kali-linux-all ${assess_update_errors}"
  $screen_cmd "${apt} install -y kali-linux-full ${assess_update_errors}"
  grok_error
else
  #echo "Other Linux Distro Detected - Skipping kali-linux-all Installation..."
  echo "Other Linux Distro Detected - Skipping kali-linux-full Installation..."
fi

$screen_cmd "${apt} install -y apt-file ${assess_update_errors}"
grok_error

$screen_cmd "apt-file update ${assess_update_errors}"
grok_error

printf 'OS updated to reasonable expectations - cleaning up screen logs...'
sudo rm screenlog.*
echo 'complete.'
