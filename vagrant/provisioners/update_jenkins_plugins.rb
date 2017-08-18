#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

print 'Updating Jenkins Plugins...'
ruby_version = File.readlines('/csi/.ruby-version')[0].to_s.scrub.strip.chomp
rvm_gemset = File.readlines('/csi/.ruby-gemset')[0].to_s.scrub.strip.chomp

jenkins_userland_config = YAML.load_file('/csi/etc/jenkins/vagrant.yaml')
userland_user = jenkins_userland_config['user']
userland_pass = jenkins_userland_config['pass']

puts `sudo bash --login -c "source /etc/profile.d/rvm.sh; rvm use ruby-#{ruby_version}@#{rvm_gemset}; csi_jenkins_update_plugins -s '127.0.0.1' -d 8888 -U #{userland_user} -p #{userland_pass}"`
