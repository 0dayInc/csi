#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING RUBY
if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

function usage() {
  echo $"Usage: $0 <new ruby version e.g. 2.4.4> <optional bool running from build_csi_gem.sh>"
  exit 1
}

source /etc/profile.d/rvm.sh

new_ruby_version=$1
if [[ $2 != '' ]]; then
  old_ruby_version=$2
else
  old_ruby_version=`cat ${csi_root}/.ruby-version`
fi

ruby_gemset=`cat ${csi_root}/.ruby-gemset`

if [[ $# < 1 ]]; then
  usage
fi

# Upgrade RVM
#curl -sSL https://get.rvm.io | sudo bash -s latest
rvmsudo rvm get latest
rvm reload

# Remove Old CSI Gemset
rvm use ruby-$old_ruby_version@global
rvm gemset --force delete $ruby_gemset
rm Gemfile.lock

# Install New Version of RubyGems & Ruby
cd $csi_root && ./vagrant/provisioners/gem.sh
rvm install ruby-$new_ruby_version
echo $new_ruby_version > $csi_root/.ruby-version

cd $csi_root && rvm use $new_ruby_version@$ruby_gemset && ./reinstall_csi_gemset.sh && ./build_csi_gem.sh
