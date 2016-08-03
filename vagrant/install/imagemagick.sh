#!/bin/bash --login
printf "Installing ImageMagick ****************************************************************"
sudo apt-get install -y imagemagick
sudo /etc/init.d/lxdm restart
