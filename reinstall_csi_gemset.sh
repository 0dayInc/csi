#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING VERSIONS IN Gemfile
source $HOME/.rvm/scripts/rvm
ruby_version=`cat .ruby-version`
ruby_gemset=`cat .ruby-gemset`
rvm use $ruby_version@global
rvm gemset --force delete $ruby_gemset
rm Gemfile.lock
rvm gemset create $ruby_gemset
rvm --default $ruby_version@$ruby_gemset
rvm use $ruby_version@$ruby_gemset
gem install bundler
if [[ $(uname -s) == "Darwin" ]]; then
  bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
fi
bundle install
