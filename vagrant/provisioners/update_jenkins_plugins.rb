#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

if ENV['CSI_ROOT']
  csi_root = ENV['CSI_ROOT']
else
  csi_root = '/csi'
end
csi_provider = ENV['CSI_PROVIDER'] if ENV['CSI_PROVIDER']
jenkins_userland_config = YAML.load_file("#{csi_root}/etc/userland/#{csi_provider}/jenkins/vagrant.yaml")
userland_user = jenkins_userland_config['user']
userland_pass = jenkins_userland_config['pass']

print 'Updating Jenkins Plugins...'
puts `/bin/bash --login -c "csi_jenkins_update_plugins -s '127.0.0.1' -d 8888 -U '#{userland_user}' -P '#{userland_pass}'"`
