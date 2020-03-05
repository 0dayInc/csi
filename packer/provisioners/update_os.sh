#!/bin/bash --login
source /etc/profile.d/globals.sh

# Automate Package Install Questions :)
# Obtain values via: debconf-get-selections | less

csi_provider=`echo $CSI_PROVIDER`

# Update OS per update_os_instructions function and grok for errors in screen session logs
# to mitigate introduction of bugs during updgrades.

# PINNED PACKAGES
# pin openssl for arachni proxy plugin Arachni/arachni#1011
$screen_cmd "echo 'Package: openssl' > /etc/apt/preferences.d/openssl ${assess_update_errors}"
grok_error

$screen_cmd "echo 'Pin: version 1.1.0*' >> /etc/apt/preferences.d/openssl ${assess_update_errors}"
grok_error

$screen_cmd "echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/openssl ${assess_update_errors}"
grok_error

# pin until breadcrumbs are implemented in the framwework
$screen_cmd "echo 'Package: jenkins' > /etc/apt/preferences.d/jenkins ${assess_update_errors}"
grok_error

$screen_cmd "echo 'Pin: version 2.190' >> /etc/apt/preferences.d/jenkins ${assess_update_errors}"
grok_error

$screen_cmd "echo 'Pin-Priority: 1002' >> /etc/apt/preferences.d/jenkins ${assess_update_errors}"
grok_error

# Cleanup up prior screenlog.0 file from previous update_os failure(s)
if [[ -e screenlog.0 ]]; then 
  sudo rm screenlog.*
fi

$screen_cmd "apt update ${assess_update_errors}"
grok_error

$screen_cmd "apt install -y debconf-i18n ${assess_update_errors}"
grok_error

$screen_cmd "echo 'samba-common samba-common/dhcp boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'libc6 libraries/restart-without-asking boolean true' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'console-setup console-setup/codeset47 select Guess optimal character set' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "echo 'wireshark-common wireshark-common/install-setuid boolean false' | ${debconf_set} ${assess_update_errors}"
grok_error

$screen_cmd "${apt} dist-upgrade -y ${assess_update_errors}"
grok_error

$screen_cmd "${apt} full-upgrade -y ${assess_update_errors}"
grok_error

grep kali /etc/apt/sources.list
if [[ $? == 0 ]]; then
   $screen_cmd "${apt} install -y kali-linux ${assess_update_errors}"
   grok_error

   $screen_cmd "${apt} install -y kali-linux-full ${assess_update_errors}"
   grok_error

   $screen_cmd "${apt} install -y kali-desktop-xfce ${assess_update_errors}"
   grok_error
else
  echo "Other Linux Distro Detected - Skipping kali-linux-full Installation..."
fi

$screen_cmd "${apt} install -y apt-file ${assess_update_errors}"
grok_error

$screen_cmd "apt-file update ${assess_update_errors}"
grok_error

$screen_cmd "${apt} autoremove -y --purge ${assess_update_errors}"
grok_error

$screen_cmd "${apt} -y clean"
grok_error

$screen_cmd "dpkg --configure -a ${assess_update_errors}"
grok_error

printf 'OS updated to reasonable expectations - cleaning up screen logs...'
sudo rm screenlog.*
echo 'complete.'
