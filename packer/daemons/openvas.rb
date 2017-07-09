#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'optparse'

opts = {}
OptionParser.new do |options|
  options.banner = "USAGE:
    #{$PROGRAM_NAME} [opts]
  "

  options.on('-aACTION', '--action=ACTION', '<Required - Daemon Action start|reload|stop>') { |a| opts[:action] = a }
end.parse!

if opts.empty?
  puts `#{$PROGRAM_NAME} --help`
  exit 1
end

action = opts[:action].to_s.scrub.to_sym

private def start
  openvas_mgr = fork do
    exec '/etc/init.d/openvas-manager start'
  end
  Process.detach(openvas_mgr)

  openvas_scan = fork do
    exec '/etc/init.d/openvas-scanner start'
  end
  Process.detach(openvas_scan)

  gsad = fork do
    exec '/etc/init.d/greenbone-security-assistant start'
  end
  Process.detach(gsad)
end

private def reload
  stop
  sleep 3
  start
end

private def stop
  gsad = fork do
    exec '/etc/init.d/greenbone-security-assistant stop'
  end
  Process.detach(gsad)

  openvas_scan = fork do
    exec '/etc/init.d/openvas-scanner stop'
  end
  Process.detach(openvas_scan)

  openvas_mgr = fork do
    exec '/etc/init.d/openvas-manager stop'
  end
  Process.detach(openvas_mgr)
end

case action
when :start
  start
when :reload
  reload
when :stop
  stop
else
  puts `#{$PROGRAM_NAME} --help`
  exit 1
end
