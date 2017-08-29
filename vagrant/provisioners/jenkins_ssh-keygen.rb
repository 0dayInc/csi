#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

jenkins_userland_config = YAML.load_file('/csi/etc/jenkins/vagrant.yaml')
userland_ssh_keygen_pass = jenkins_userland_config['ssh_keygen_pass']
hostname = `hostname`.to_s.chomp.strip.scrub

print 'Creating SSH Key for Userland Jenkins Jobs...'
puts `sudo -H -u jenkins ssh-keygen -t rsa -b 4096 -C jenkins@#{hostname} -N #{userland_ssh_keygen_pass} -f '/var/lib/jenkins/.ssh/id_rsa-csi_jenkins'`

puts 'The following is the public SSH key created for Jenkins:'
puts `sudo cat /var/lib/jenkins/.ssh/id_rsa-csi_jenkins.pub`
puts 'If you intend on leveraging User-Land jobs that will connect to remote hosts via SSH'
puts 'please ensure you add the aforementioned public key value to your respective ~/.ssh/authorized_keys file.'
