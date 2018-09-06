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
      sleep 30
    fi
  done
}

# Update OS per update_os_instructions function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.

screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'
assess_update_errors='|| echo UPDATE_ABORT && exit 1'

update_os_instructions=(
  "apt update"
  "echo 'samba-common samba-common/dhcp boolean false' | debconf-set-selections ${assess_update_errors}"
  "echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections ${assess_update_errors}"
  "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | debconf-set-selection ${assess_update_errors}"
  "echo 'grub-pc grub-pc/install_devices multiselect /dev/sda1' | debconf-set-selections ${assess_update_errors}"
  "echo 'wireshark-common wireshark-common/install-setuid boolean false' | debconf-set-selections ${assess_update_errors}"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y ${assess_update_errors}"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade -y ${assess_update_errors}"
  "apt autoremove -y ${assess_update_errors}"
  "apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -y apt-file ${assess_update_errors}"
  "apt-file update ${assess_update_errors}"
  "apt install -y kali-linux-all ${assess_update_errors}"
)

for instruction in ${update_os_instructions[@]}; do
  $screen_cmd $instruction
  grok_error
done

printf 'OS updated to reasonable expectations - cleaning up screen logs...'
sudo rm screenlog.*
echo 'complete.'

