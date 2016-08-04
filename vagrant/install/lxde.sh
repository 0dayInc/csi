#!/bin/bash --login
printf "Installing LXDE ***********************************************************************"
sudo /bin/bash --login -c "apt-get install -y lxde lxdm && sed -i 's/bg=\/usr\/share\/images\/desktop-base\/login-background\.svg/bg=\/etc\/alternatives\/desktop\-background/g' /etc/lxdm/default.conf && /etc/init.d/lxdm restart && ln -sf /csi/third_party/virtualbox-gui_wallpaper.jpg /etc/alternatives/desktop-background"
