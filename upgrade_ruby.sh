#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING RUBY

function usage() {
  echo $"Usage: $0 <new ruby version e.g. 2.4.4>"
  exit 1
}

source /etc/profile.d/rvm.sh

new_ruby_version=$1
old_ruby_version=$(cat /csi/.ruby-version)
ruby_gemset=$(cat /csi/.ruby-gemset)

if [[ $new_ruby_version != '' ]]; then
  # Remove Old CSI Gemset
  rvm use ruby-$old_ruby_version@global
  rvm gemset --force delete $ruby_gemset
  rm Gemfile.lock

  # Install New Version of Ruby
  rvm install ruby-$new_ruby_version
  echo $new_ruby_version > /csi/.ruby-version

  cd /csi && ./reinstall_csi_gemset.sh
else
  usage
fi
