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
if [[ -f "${csi_root}/Gemfile.lock" ]]; then
  rm $csi_root/Gemfile.lock
fi

rvm use ruby-$ruby_version@$ruby_gemset --create
export rvmsudo_secure_path=1
rvmsudo gem install bundler
if [[ $(uname -s) == "Darwin" ]]; then
  bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
  bundle config build.serialport --with-cflags=-Wno-implicit-function-declaration
fi
bundle install
# bundle install --full-index
rvm --default ruby-$ruby_version@$ruby_gemset
