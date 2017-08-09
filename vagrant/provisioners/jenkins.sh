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

csi_jenkins_useradd -s 127.0.0.1 -S 8080 -u $new_user -p $new_pass -U admin -P $initial_admin_pwd -e $new_email

# Begin Creating Self-Update Jobs in Jenkins and Template-Based Jobs to Describe how to Intgrate CSI into Jenkins
printf "Creating Self-Update Jobs *************************************************************"
csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-os \
  -c /csi/etc/jenkins/jobs/selfupdate-os.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-rvm \
  -c /csi/etc/jenkins/jobs/selfupdate-rvm.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-gem \
  -c /csi/etc/jenkins/jobs/selfupdate-gem.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-wpscan \
  -c /csi/etc/jenkins/jobs/selfupdate-wpscan.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-metasploit \
  -c /csi/etc/jenkins/jobs/selfupdate-metasploit.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-ssllabs-scan \
  -c /csi/etc/jenkins/jobs/selfupdate-ssllabs-scan.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-openvas_sync \
  -c /csi/etc/jenkins/jobs/selfupdate-openvas_sync.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-csi \
  -c /csi/etc/jenkins/jobs/selfupdate-csi.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j selfupdate-exploit-db \
  -c /csi/etc/jenkins/jobs/selfupdate-exploit-db.xml

csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
  -U admin \
  -P $initial_admin_pwd \
  -j anonymization-toggle_tor \
  -c /csi/etc/jenkins/jobs/anonymization-toggle_tor.xml

# Create any jobs residing in /csi/jenkins/jobs_userland
ls /csi/etc/jenkins/jobs_userland/*.xml | while read jenkins_xml_config; do
  file_name=`basename $jenkins_xml_config`
  job_name=${file_name%.*}
  csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
    -U admin \
    -P $initial_admin_pwd \
    -j $job_name \
    -c /csi/etc/jenkins/jobs_userland/$jenkins_xml_config
done
