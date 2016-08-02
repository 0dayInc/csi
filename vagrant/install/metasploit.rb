#!/usr/bin/env ruby
require 'yaml'

# Install Metasploit from Source
# TODO: Install/Upgrade Metasploit w/in CSI::Plugins::Metasploit Module
printf "Installing Metasploit *****************************************************************"
metasploit_root = "/opt/metasploit-framework-dev"
`sudo git clone https://github.com/rapid7/metasploit-framework.git #{metasploit_root}`
metasploit_ruby_version = File.readlines("#{metasploit_root}/.ruby-version")[0].to_s.scrub.strip.chomp
metasploit_gemset = File.readlines("#{metasploit_root}/.ruby-gemset")[0].to_s.scrub.strip.chomp
`sudo bash --login -c "source /etc/profile.d/rvm.sh && rvm install ruby-#{metasploit_ruby_version} && rvm use ruby-#{metasploit_ruby_version} && rvm gemset create #{metasploit_gemset} && cd #{metasploit_root} && gem install bundler && bundle install"`

# TODO: Startup MSFRPCD Daemon using SP config
printf "Starting up MSFRPCD *******************************************************************"
msfrpcd_config = YAML.load_file('/csi/etc/metasploit/msfrpcd.yaml')
msfrpcd_host = msfrpcd_config['msfrpcd_host'].to_s.scrub.strip.chomp
msfrpcd_port = msfrpcd_config['port'].to_i
msfrpcd_user = msfrpcd_config['username'].to_s.scrub.chomp # Don't strip leading space
msfrpcd_pass = msfrpcd_config['password'].to_s.scrub.chomp # Don't strip leading space
system("sudo bash --login -c \"source /etc/profile.d/rvm.sh && rvm use ruby-#{metasploit_ruby_version}@#{metasploit_gemset} && cp /csi/etc/systemd/msfrpcd.service /etc/systemd/system/ && systemctl enable msfrpcd.service && systemctl start msfrpcd.service\"")
