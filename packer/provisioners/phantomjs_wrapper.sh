#!/bin/bash --login
source /etc/profile.d/rvm.sh
ruby_version=$(cat /csi/.ruby-version)
rvm use ruby-$ruby_version@csi

# This is needed to ensure other ruby installations aren't picked up
# by #!/usr/bin/env ruby inside of the script below
# /csi/packer/provisioners/phantomjs.rb
sudo apt install phantomjs
