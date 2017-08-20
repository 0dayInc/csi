#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING VERSIONS IN Gemfile
source /etc/profile.d/rvm.sh
ruby_version=$(cat /csi/.ruby-version)
ruby_gemset=$(cat /csi/.ruby-gemset)
rvm use ruby-$ruby_version@global
rvm gemset --force delete $ruby_gemset
rm Gemfile.lock
rvm gemset create $ruby_gemset
rvm use ruby-$ruby_version@$ruby_gemset
gem install bundler
if [[ $(uname -s) == "Darwin" ]]; then
  bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
fi
bundle install
rvm --default ruby-$ruby_version@$ruby_gemset
