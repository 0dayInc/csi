#!/usr/bin/env ruby
require 'csi'

printf "Installing Owasp ZAP ******************************************************************"
owasp_zap_tar_gz = ''
owasp_zap_tar_extraction_path = '/opt/owasp_zap-releases'
owasp_zap_linux_download = ''
url = "https://github.com/zaproxy/zaproxy/wiki/Downloads"
# Look for specific links w/ pattern matching Linux tar.gz
browser_obj = CSI::Plugins::TransparentBrowser.open(:browser_type => :headless)
browser_obj.goto(url)

browser_obj.links.each do |link|
  if link.href =~ /ZAP_.+_Linux\.tar\.gz/
    owasp_zap_tar_gz = "/opt/#{File.basename(link.href)}"
    owasp_zap_linux_download = link.href
  end
end

unless File.exists?(owasp_zap_tar_gz)
  puts `sudo wget -O #{owasp_zap_tar_gz} #{owasp_zap_linux_download}`
end

puts `sudo mkdir -p #{owasp_zap_tar_extraction_path}` unless Dir.exists?(owasp_zap_tar_extraction_path)
puts `sudo tar -xzvf #{owasp_zap_tar_gz} -C #{owasp_zap_tar_extraction_path}`
puts `sudo rm #{owasp_zap_tar_gz}`
