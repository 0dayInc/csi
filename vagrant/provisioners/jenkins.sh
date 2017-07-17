#!/bin/bash --login
# Make sure the csi gemset has been loaded
source /etc/profile.d/rvm.sh
ruby_version=`cat /csi/.ruby-version`
rvm use $ruby_version@csi

initial_admin_pwd=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

printf "Creating User *************************************************************************"
new_user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['user']"`
new_pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['pass']"`
new_fullname=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['fullname']"`
new_email=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['email']"`
csi_jenkins_useradd --jenkins_ip -s 127.0.0.1 -S 8080 -u $new_user -p $new_pass -U admin -P $initial_admin_pwd
