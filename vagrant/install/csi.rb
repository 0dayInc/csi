#!/usr/bin/env ruby
# frozen_string_literal: true
printf "Installing CSI Dependencies ***********************************************************"
`sudo apt-get install -y fontconfig postgresql-server-dev-all`

printf "Performing Bundle Install and Installing csi Gem **************************************"
`sudo bash --login -c "source /etc/profile.d/rvm.sh && cd /csi && gem install bundler && bundle install && rake && rake install && rake rerdoc && gem rdoc --rdoc --ri --overwrite -V csi"`
