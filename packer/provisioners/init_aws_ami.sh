#!/bin/bash --login
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

screen_cmd='sudo screen -L -S update_os -d -m /bin/bash --login -c'
assess_update_errors='|| echo UPDATE_ABORT && exit 1'

# Cleanup up prior screenlog.0 file from previous update_os failure(s)
if [[ -e screenlog.0 ]]; then
  sudo rm screenlog.*
fi

$screen_cmd "apt install -y grub-legacy ${assess_update_errors}"
grok_error

$screen_cmd "grub-set-default 1 ${assess_update_errors}"
grok_error

$screen_cmd "update-grub ${assess_update_errors}"
grok_error

$screen_cmd "sed -i 's/timeout 5/timeout 9/g' /boot/grub/menu.lst ${assess_update_errors}"
grok_error

$screen_cmd "sed -i 's/.*kopt=root=.*/# kopt=root=/dev/xvda console=hvc0 ro quiet/g' /boot/grub/menu.lst ${assess_update_errors}"
grok_error

$screen_cmd "sed -i 's/.*groot=.*/# groot=(hd0)/g' /boot/grub/menu.lst ${assess_update_errors}"
grok_error

$screen_cmd "update-grub ${assess_update_errors}"
grok_error
