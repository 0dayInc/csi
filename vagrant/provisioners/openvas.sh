#!/bin/bash
user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/openvas/vagrant.yaml')['user']"`
pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/openvas/vagrant.yaml')['pass']"`
sudo /bin/bash --login -c 'greenbone-certdata-sync && greenbone-nvt-sync && greenbone-scapdata-sync'
sudo /bin/bash --login -c "openvasmd --user=${user} --new-password=${pass}"
