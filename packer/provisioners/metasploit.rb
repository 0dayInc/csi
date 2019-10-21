#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

# Install Metasploit from Source
printf 'Installing Metasploit *****************************************************************'
if ENV['CSI_ROOT']
  csi_root = ENV['CSI_ROOT']
elsif Dir.exist?('/csi')
  csi_root = '/csi'
else
  csi_root = Dir.pwd
end

csi_provider = ENV['CSI_PROVIDER'] if ENV['CSI_PROVIDER']

metasploit_root = '/opt/metasploit-framework-dev'
`sudo git clone https://github.com/rapid7/metasploit-framework.git #{metasploit_root}`
`sudo apt install -y libpq-dev postgresql-server-dev-all`
metasploit_ruby_version = File.readlines("#{metasploit_root}/.ruby-version")[0].to_s.scrub.strip.chomp
metasploit_gemset = File.readlines("#{metasploit_root}/.ruby-gemset")[0].to_s.scrub.strip.chomp
`sudo bash --login -c "source /etc/profile.d/rvm.sh && rvm install ruby-#{metasploit_ruby_version} && rvm use ruby-#{metasploit_ruby_version} && rvm gemset create #{metasploit_gemset} && cd #{metasploit_root} && gem install bundler && bundle install"`

printf 'Starting up MSFRPCD *******************************************************************'
system("sudo bash --login -c 'cp #{csi_root}/etc/userland/#{csi_provider}/metasploit/vagrant.yaml.EXAMPLE #{csi_root}/etc/userland/#{csi_provider}/metasploit/vagrant.yaml'")
system("sudo bash --login -c \"source /etc/profile.d/rvm.sh && rvm use ruby-#{metasploit_ruby_version}@#{metasploit_gemset} && cp #{csi_root}/etc/systemd/msfrpcd.service /etc/systemd/system/ && systemctl enable msfrpcd.service && systemctl start msfrpcd.service\"")
