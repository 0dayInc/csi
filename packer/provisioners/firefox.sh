#!/bin/bash --login
printf "Installing Firefox ********************************************************************"
debian_unstable_sources='/etc/apt/sources.list.d/debian-unstable.list'
sudo /bin/bash --login -c "echo deb http://ftp.debian.org/debian unstable main contrib non-free > ${debian_unstable_sources}"
sudo /bin/bash --login  -c "echo deb deb http://deb.debian.org/debian experimental main >> ${debian_unstable_sources}"
sudo apt update
sudo apt install -y firefox
