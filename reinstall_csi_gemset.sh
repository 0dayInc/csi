#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING VERSIONS IN Gemfile
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
ruby_gemset=`cat ${csi_root}/.ruby-gemset`
rvm use ruby-$ruby_version@global
rvm gemset --force delete $ruby_gemset
rm Gemfile.lock
# rvm gemset create $ruby_gemset
rvm use ruby-$ruby_version@$ruby_gemset --create
gem install bundler
if [[ $(uname -s) == "Darwin" ]]; then
  bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
fi
# Once aws-sdk-resources begins behaving again, uncomment this to speed things up:
# bundle install
bundle install --full-index
rvm --default ruby-$ruby_version@$ruby_gemset
