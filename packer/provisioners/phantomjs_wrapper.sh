#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  csi_root='/csi'
else
  csi_root="${CSI_ROOT}"
fi

source /etc/profile.d/rvm.sh
ruby_version=`cat ${csi_root}/.ruby-version`
rvm use ruby-$ruby_version@csi

# This is needed to ensure other ruby installations aren't picked up
# by #!/usr/bin/env ruby inside of the script below
# /csi/packer/provisioners/phantomjs.rb
sudo apt install phantomjs
