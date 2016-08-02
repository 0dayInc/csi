#!/usr/bin/env ruby
print "Updating Arachni Web Vulnerability Scanner..."
Dir.chdir("/opt")
arachni_root = "/opt/arachni-dev/"
puts `sudo /bin/bash --login -c "cd #{arachni_root} && git pull"`
arachni_ruby_version = '2.3.0'
arachni_gemset = 'arachni'
puts `sudo bash --login -c "source /etc/profile.d/rvm.sh; rvm install ruby-#{arachni_ruby_version}; rvm use ruby-#{arachni_ruby_version}; rvm gemset create #{arachni_gemset}; rvm use ruby-#{arachni_ruby_version}@#{arachni_gemset}; cd #{arachni_root}; gem install bundler; bundle install; rake install"`
puts "complete."
