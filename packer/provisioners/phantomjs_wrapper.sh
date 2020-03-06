#!/bin/bash --login
source /etc/profile.d/globals.sh

if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

source /etc/profile.d/rvm.sh
ruby_version=`cat ${csi_root}/.ruby-version`
rvm use ruby-$ruby_version@csi

# This is needed to ensure other ruby installations aren't picked up
# by #!/usr/bin/env ruby inside of the script below
# /csi/packer/provisioners/phantomjs.rb
$screen_cmd "${apt} install phantomjs ${assess_update_errors}"
grok_error
