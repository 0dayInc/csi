#!/usr/bin/env ruby
# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'net/http'
require 'rubygems/package'
require 'zlib'

printf 'Installing Arachni ********************************************************************'
TAR_LONGLINK = '././@LongLink'
nightly_tar_gz = ''
nightly_tar_extraction_path = '/opt/arachni-nightlies'
nightly_linux_download = ''
url = 'http://downloads.arachni-scanner.com/nightlies'
print 'Installing Arachni Web Vulnerability Scanner...'
# Look for specific links w/ pattern matching 64 bit linux tar.gz
nightly_resp = RestClient.get(url)
links = Nokogiri::HTML(nightly_resp).xpath('//a/@href')
links.each do |link|
  if link.value =~ /linux-x86_64\.tar\.gz/
    nightly_tar_gz = "#{nightly_tar_extraction_path}/#{link.value}"
    nightly_linux_download = "#{url}/#{link.value}"
  end
end



# TODO: Convert to CSI::Core Module - Now download file
unless File.exists?(nightly_tar_gz)
  `sudo wget -O #{nightly_tar_gz} #{nightly_linux_download}`
end

`sudo mkdir -p #{nightly_tar_extraction_path}` unless Dir.exists?(nightly_tar_extraction_path)
puts `sudo tar -xzvf #{nightly_tar_gz} -C #{nightly_tar_extraction_path}`
`sudo rm #{nightly_tar_gz}`
