#!/bin/bash --login
printf "Installing LXDE ***********************************************************************"
sudo /bin/bash --login -c "apt-get install -y lxde lxdm && /etc/init.d/lxdm restart && ln -sf /csi/virtualbox-gui_wallpaper.jpg /etc/alternatives/desktop-background"
