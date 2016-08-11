#!/usr/bin/env ruby
require 'yaml'

print "Installing Let's Encrypt **************************************************************"
letsencrypt_root = "/opt/letsencrypt-git"
letsencrypt_yaml = YAML.load_file('/csi/etc/letsencrypt/vagrant.yaml')
letsencrypt_domains = letsencrypt_yaml["domains"] 
letsencrypt_email = letsencrypt_yaml["email"].to_s.scrub.strip.chomp

letsencrypt_flags = "--apache"
letsencrypt_domains.each {|domain| letsencrypt_flags << "\s-d #{domain}" }
letsencrypt_flags << "\s--non-interactive --agree-tos --text --email #{letsencrypt_email}"

system("sudo -i /bin/bash --login -c \"git clone https://github.com/letsencrypt/letsencrypt #{letsencrypt_root} && cd #{letsencrypt_root} && ./letsencrypt-auto #{letsencrypt_flags}\"")
