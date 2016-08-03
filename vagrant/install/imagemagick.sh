#!/bin/bash --login
printf "Installing ImageMagick ****************************************************************"
sudo apt-get install -y libmagickwand-dev imagemagick
sudo /etc/init.d/lxdm restart
