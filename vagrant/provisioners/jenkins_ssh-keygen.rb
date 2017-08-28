#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

jenkins_userland_config = YAML.load_file('/csi/etc/jenkins/vagrant.yaml')
userland_ssh_keygen_pass = jenkins_userland_config['ssh_keygen_pass']
hostname = `hostname`.to_s.chomp.strip.scrub

print 'Creating SSH Key for Userland Jenkins Jobs...'
puts `sudo -H -u jenkins ssh-keygen -t rsa -b 4096 -C jenkins@#{hostname} -N #{userland_ssh_keygen_pass} -f '/var/lib/jenkins/.ssh/id_rsa-csi_jenkins'`
