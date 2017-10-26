#!/usr/bin/env ruby
# frozen_string_literal: true

alias_file = '/etc/profile.d/aliases.sh'
File.open(alias_file, 'w') do |f|
  f.puts '#!/bin/bash'
  f.puts "alias kpid='kill -15'"
  f.puts "alias prep='ps -ef | grep'"
  f.puts "alias sup='sudo su -'"
  f.puts "alias vi='vim -i NONE'"
  f.puts "alias vim='vim -i NONE'"
end
# 0o755 is not a typo - Octal literals are required by rubocop
File.chmod(0o755, alias_file)
