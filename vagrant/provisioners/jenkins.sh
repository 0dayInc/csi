#!/bin/bash --login
# Make sure the csi gemset has been loaded
source /etc/profile.d/rvm.sh
ruby_version=$(cat /csi/.ruby-version)
rvm use ruby-$ruby_version@csi

initial_admin_pwd=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

printf "Creating User *************************************************************************"
new_user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['user']"`
new_pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['pass']"`
new_fullname=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['fullname']"`
new_email=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['email']"`

csi_jenkins_useradd -s 127.0.0.1 -d 8888 -u $new_user -p $new_pass -U admin -P $initial_admin_pwd -e $new_email

# Begin Creating Self-Update Jobs in Jenkins and Template-Based Jobs to Describe how to Intgrate CSI into Jenkins
printf "Creating Self-Update and CSI-Template Jobs ********************************************"
ls /csi/etc/jenkins/jobs/*.xml | while read jenkins_xml_config; do
  file_name=`basename $jenkins_xml_config`
  job_name=${file_name%.*}
  csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
    -d 8888 \
    -U admin \
    -P $initial_admin_pwd \
    -j $job_name \
    -c $jenkins_xml_config
done

# Create any jobs residing in /csi/jenkins/jobs_userland
ls /csi/etc/jenkins/jobs_userland/*.xml 2> /dev/null
if [[ $? == 0 ]]; then
  printf "Creating User-Land Jobs ***************************************************************"
  ls /csi/etc/jenkins/jobs_userland/*.xml | while read jenkins_xml_config; do
    file_name=`basename $jenkins_xml_config`
    job_name=${file_name%.*}
    csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
      -d 8888 \
      -U admin \
      -P $initial_admin_pwd \
      -j $job_name \
      -c $jenkins_xml_config
  done
fi

printf "Creating Jenkins Views ****************************************************************"
csi_jenkins_create_view --jenkins_ip 127.0.0.1 \
  -d 8888 \
  -U admin \
  -P $initial_admin_pwd \
  -v 'CSI-Templates' \
  -r '^csitemplate-.+$'

csi_jenkins_create_view --jenkins_ip 127.0.0.1 \
  -d 8888 \
  -U admin \
  -P $initial_admin_pwd \
  -v 'Self-Update' \
  -r '^selfupdate-.+$'

csi_jenkins_create_view --jenkins_ip 127.0.0.1 \
  -d 8888 \
  -U admin \
  -P $initial_admin_pwd \
  -v 'Pipeline' \
  -r '^pipeline-.+$'

csi_jenkins_create_view --jenkins_ip 127.0.0.1 \
  -d 8888 \
  -U admin \
  -P $initial_admin_pwd \
  -v 'User-Land' \
  -r '^userland-.+$'
