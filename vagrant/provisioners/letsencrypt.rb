#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

print "Installing Let's Encrypt **************************************************************"
if ENV['CSI_ROOT']
  csi_root = ENV['CSI_ROOT']
else
  if Dir.exists?('/csi')
    csi_root = '/csi'
  else
    csi_root = Dir.pwd
  end
end

csi_provider = ENV['CSI_PROVIDER'] if ENV['CSI_PROVIDER']
letsencrypt_root = '/opt/letsencrypt-git'
letsencrypt_yaml = YAML.load_file("#{csi_root}/etc/userland/#{csi_provider}/letsencrypt/vagrant.yaml")
letsencrypt_domains = letsencrypt_yaml['domains']
letsencrypt_email = letsencrypt_yaml['email'].to_s.scrub.strip.chomp

letsencrypt_flags = '--apache'
letsencrypt_domains.each { |domain| letsencrypt_flags = "#{letsencrypt_flags} -d #{domain}" }
letsencrypt_flags = "#{letsencrypt_flags} --non-interactive --agree-tos --text --email #{letsencrypt_email}"

system("sudo -i /bin/bash --login -c \"git clone https://github.com/letsencrypt/letsencrypt #{letsencrypt_root} && cd #{letsencrypt_root} && ./letsencrypt-auto #{letsencrypt_flags}\"")
