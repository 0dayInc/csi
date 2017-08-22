#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

userland_burpsuite_pro_jar_path = '/csi/third_party/burpsuite-pro.jar'
if File.exist?(userland_burpsuite_pro_jar_path)
  burpsuite_pro_yaml = YAML.load_file('/csi/etc/burpsuite/vagrant.yaml')
  burpsuite_pro_jar_sha256_sum = burpsuite_pro_yaml['burpsuite_pro_jar_sha256_sum']
  license_key = burpsuite_pro_yaml['license_key'].to_s.scrub.strip.chomp

  this_sha256_sum = Digest::SHA256.file(userland_burpsuite_pro_jar_path).to_s

  if this_sha256_sum == burpsuite_pro_jar_sha256_sum
    # TODO: rsync userland_burpsuite_pro_jar_path to /opt/burpsuite
  end
end
