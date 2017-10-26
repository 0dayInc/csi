#!/usr/bin/env ruby
alias_file = '/etc/profile.d/aliases.sh'
File.open(alias_file, 'w') do |f|
  f.puts '#!/bin/bash'
  f.puts "alias kpid='kill -15'"
  f.puts "alias prep='ps -ef | grep'"
  f.puts "alias sup='sudo su -'"
  f.puts "alias vi='vim -i NONE'"
  f.puts "alias vim='vim -i NONE'"
end
File.chmod(0755, alias_file)
