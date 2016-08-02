#!/bin/bash --login
# USE THIS SCRIPT WHEN UPGRADING VERSIONS IN Gemfile
source $HOME/.rvm/scripts/rvm
ruby_version=`cat .ruby-version`
rvm use $ruby_version@global
rvm gemset delete csi
rm Gemfile.lock
rvm gemset create csi
rvm use $ruby_version@csi
gem install bundler
bundle install
