#!/bin/bash --login

csi_golden_image=`echo $CSI_GOLDEN_IMAGE`
screen_cmd='sudo screen -L -S init_image -d -m /bin/bash --login -c'
assess_update_errors='|| echo UPDATE_ABORT && exit 1'
debconf_set='/usr/bin/debconf-set-selections'
apt="DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confnew'"

grok_error() {
  while true; do
    # Wait until screen exits session
    sudo screen -ls | grep init_image
    if [[ $? == 1 ]]; then
      grep UPDATE_ABORT screenlog.*
      if [[ $? == 0 ]]; then
        echo 'Failures encountered in screenlog for init_image session!!!'
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

case $csi_golden_image in
  'aws_ami')
     # Begin Converting to Kali Rolling
     $screen_cmd "${apt} install -yq dirmngr software-properties-common ${assess_update_errors}"
     grok_error

     $screen_cmd "> /etc/apt/sources.list && add-apt-repository 'deb https://http.kali.org/kali kali-rolling main non-free contrib' && echo 'deb-src https://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list ${assess_update_errors}"
     grok_error

     # Download and import the official Kali Linux key
     $screen_cmd "wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add ${assess_update_errors}"
     grok_error

     # Update our apt db so we can install kali-keyring
     $screen_cmd "apt update ${assess_update_errors}"
     grok_error

     # Install the Kali keyring
     $screen_cmd "${apt} install -yq kali-archive-keyring ${assess_update_errors}"
     grok_error

     # Update our apt db again now that kali-keyring is installed
     $screen_cmd "apt update ${assess_update_errors}"
     grok_error
     ;;

  'qemu') sudo useradd -m -s /bin/bash admin
                $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
                grok_error
                ;;

  'virtualbox') sudo useradd -m -s /bin/bash admin
                grok_error

                sudo usermod -aG sudo admin
                grok_error
                ;;

  'vmware') sudo useradd -m -s /bin/bash admin
            grok_error

            sudo usermod -aG sudo admin
            grok_error
            ;;

  *) echo 'error: unknown csi_golden_image_value'
     exit 1
     ;;
esac
