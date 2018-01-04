#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csi'
require 'optparse'

opts = {}
OptionParser.new do |options|
  options.banner = "USAGE:
    #{$PROGRAM_NAME} [opts]
  "

  options.on('-pPROXY', '--proxy=PROXY', '<Optional - HTTP or Socks Proxy>') do |p|
    opts[:proxy] = p
  end

  options.on('-T', '--[no-]with-tor', '<Optional - Proxy w/ TOR (Defaults to false)>') do |w|
    opts[:with_tor] = w
  end

  options.on('-r', '--regex', '<Required - Regex Pattern for Interesting Pastes (* for All)>') do |r|
    opts[:ipinfo] = r
  end
end.parse!

if opts.empty?
  puts `#{$PROGRAM_NAME} --help`
  exit 1
end

proxy = opts[:proxy]
with_tor = opts[:with_tor]
regex = opts[:regex]

browser_obj = CSI::WWW::Pastebin.open(
  browser_type: :headless,
  proxy: proxy,
  with_tor: with_tor
)

begin
  loop do
    puts "Navigating to: #{browser_obj.div(id: 'menu_2').links[0].text}"
    browser_obj.div(id: 'menu_2').links[0].click
    puts "Current Link: #{browser_obj.url}"
    code_frame = browser_obj.div(id: 'code_frame').text
    if code_frame.match?(/#{regex}/mi)
      puts "#{code_frame}\n"
    else
      print "Regex: #{regex} not found in #{browser_obj.url}"
    end
    sleep 9
  end
rescue StandardError => e
  raise e
ensure
  unless browser_obj.nil?
    browser_obj = CSI::Plugins::TransparentBrowser.close(browser_obj: browser_obj) if browser_obj == RestClient
  end
end
