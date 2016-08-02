#!/usr/bin/env ruby
print "Updating Metasploit..."
metasploit_root = "/opt/metasploit-framework-dev/"
puts `sudo /bin/bash --login -c "cd #{metasploit_root} && git pull"`
metasploit_ruby_version = File.readlines("#{metasploit_root}/.ruby-version")[0].to_s.scrub.strip.chomp
puts `sudo bash --login -c "source /etc/profile.d/rvm.sh; rvm install ruby-#{metasploit_ruby_version}; rvm use ruby-#{metasploit_ruby_version}; rvm gemset create metasploit-framework; cd #{metasploit_root}; gem install bundler && bundle install"`
puts "complete."
