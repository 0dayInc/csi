#!/bin/bash
# Update user/pass based on UserLand Configs
user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/openvas/vagrant.yaml')['user']"`
pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/openvas/vagrant.yaml')['pass']"`
sudo /bin/bash --login -c "openvasmd --user=${user} --new-password=${pass}"
