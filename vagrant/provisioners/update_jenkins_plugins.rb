#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

jenkins_userland_config = YAML.load_file('/csi/etc/jenkins/vagrant.yaml')
userland_user = jenkins_userland_config['user']
userland_pass = jenkins_userland_config['pass']

print 'Updating Jenkins Plugins...'
puts `/bin/bash --login -c "csi_jenkins_update_plugins -s '127.0.0.1' -d 8888 -U '#{userland_user}' -p '#{userland_pass}'"`
