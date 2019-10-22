#!/bin/bash --login

csi_provider=`echo $CSI_PROVIDER`
screen_cmd='sudo screen -L -S init_image -d -m /bin/bash --login -c'
assess_update_errors='|| echo IMAGE_ABORT && exit 1'
debconf_set='/usr/bin/debconf-set-selections'
apt="DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confnew'"

grok_error() {
  while true; do
    # Wait until screen exits session
    sudo screen -ls | grep init_image
    if [[ $? == 1 ]]; then
      grep IMAGE_ABORT screenlog.*
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

$screen_cmd "echo \"export CSI_ROOT='/csi'\" > /etc/profile.d/csi_envs.sh"
$screen_cmd "echo \"export CSI_ROOT='${csi_provider}'\" >> /etc/profile.d/csi_envs.sh"
$screen_cmd "chmod 755 /etc/profile.d/csi_envs.sh"

case $csi_provider in
  'aws')
    # Begin Converting to Kali Rolling
    $screen_cmd "${apt} install -y gnupg2 dirmngr software-properties-common ${assess_update_errors}"
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
    $screen_cmd "${apt} install -y kali-archive-keyring ${assess_update_errors}"
    grok_error

    # Update our apt db again now that kali-keyring is installed
    $screen_cmd "apt update ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-linux ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-linux-full ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} install -y kali-desktop-gnome ${assess_update_errors}"
    grok_error

    $screen_cmd "dpkg --configure -a ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} -y autoremove --purge ${assess_update_errors}"
    grok_error

    $screen_cmd "${apt} -y clean"
    grok_error
    ;;

  'qemu') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

    $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
    grok_error
    ;;

  'virtualbox') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

    $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
    grok_error
    ;;

  'vmware') 
    $screen_cmd "useradd -m -s /bin/bash admin ${assess_update_errors}"
    grok_error

   $screen_cmd "usermod -aG sudo admin ${assess_update_errors}"
   grok_error
   ;;

  *) echo "ERROR: Unknown CSI Provider: ${csi_provider}"
     exit 1
     ;;
esac

# Restrict Home Directory
sudo chmod 700 /home/admin

printf 'Image Initialized to reasonable expectations - cleaning up screen logs...'
sudo rm screenlog.*
echo 'complete.'
