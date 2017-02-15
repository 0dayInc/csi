#!/bin/bash --login
printf "Installing Ruby Dependencies **********************************************************"
sudo apt-get install -y build-essential bison openssl libreadline6 libreadline6-dev curl git-core git zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool libpcap-dev libsqlite3-dev libgmp-dev

source /etc/profile.d/rvm.sh
ruby_version=`cat /csi/.ruby-version`
printf "Installing ${ruby_version} ************************************************************"
sudo bash --login -c "source /etc/profile.d/rvm.sh && rvm install ${ruby_version} && rvm use ${ruby_version} && rvm gemset create csi && rvm --default ${ruby_version}@csi && rvm use ${ruby_version}@csi"
