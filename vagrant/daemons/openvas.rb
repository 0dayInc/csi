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
  openvas = fork do
    exec 'openvasmd --listen=127.0.0.1 && openvassd && gsad --listen=127.0.0.1 --port=9392 --http-only'
  end
  Process.detach(openvas)
end

private def reload
  stop
  sleep 3
  start
end

private def stop
  openvas = fork do
    exec 'killall -9 gsad && killall -9 openvassd && killall -9 openvasmd'
  end
  Process.detach(openvas)
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
