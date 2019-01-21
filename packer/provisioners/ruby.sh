#!/bin/bash --login
os=$(uname -s)

case $os in
  'Darwin')
    sudo port -N install bison openssl curl git zlib libyaml libxml2 autoconf ncurses automake libtool libpcap
    ;;
  'Linux')
    sudo apt install -y build-essential bison openssl libreadline-dev curl git-core git zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool libpcap-dev libsqlite3-dev libgmp-dev
    ;;
  *)
    echo "${os} not currently supported."
    exit 1
esac


# We clone CSI here instead of csi.sh so ruby knows what version of ruby to install
# per the latest value of .ruby-version in the repo.
sudo /bin/bash --login -c 'cd / && git clone https://github.com/0dayinc/csi.git'

ruby_version=$(cat /csi/.ruby-version)
ruby_gemset=$(cat /csi/.ruby-gemset)
sudo /bin/bash --login -c "source /etc/profile.d/rvm.sh && rvm install ruby-${ruby_version}"
