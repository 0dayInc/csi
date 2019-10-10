#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  csi_root='/csi'
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`
jenkins_userland_root="${csi_root}/etc/userland/${csi_provider}/jenkins"
jenkins_vagrant_yaml="${jenkins_userland_root}/vagrant.yaml"

# Make sure the csi gemset has been loaded
source /etc/profile.d/rvm.sh
ruby_version=`cat ${csi_root}/.ruby-version`
rvm use ruby-$ruby_version@csi

initial_admin_pwd=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

printf "Creating User *************************************************************************"
new_user=`ruby -e "require 'yaml'; print YAML.load_file('${jenkins_vagrant_yaml}')['user']"`
new_pass=`ruby -e "require 'yaml'; print YAML.load_file('${jenkins_vagrant_yaml}')['pass']"`
new_fullname=`ruby -e "require 'yaml'; print YAML.load_file('${jenkins_vagrant_yaml}')['fullname']"`
new_email=`ruby -e "require 'yaml'; print YAML.load_file('${jenkins_vagrant_yaml}')['email']"`

csi_jenkins_useradd -s 127.0.0.1 -d 8888 -u $new_user -p $new_pass -U admin -P $initial_admin_pwd -e $new_email

# Begin Creating Self-Update Jobs in Jenkins and Template-Based Jobs to Describe how to Intgrate CSI into Jenkins
printf "Creating Self-Update and CSI-Template Jobs ********************************************"
ls $jenkins_userland_root/jobs/*.xml | while read jenkins_xml_config; do
  file_name=`basename $jenkins_xml_config`
  job_name=${file_name%.*}
  csi_jenkins_create_job --jenkins_ip 127.0.0.1 \
    -d 8888 \
    -U admin \
    -P $initial_admin_pwd \
    -j $job_name \
    -c $jenkins_xml_config
done

# Create any jobs residing in $csi_root/etc/userland/$csi_provider/jenkins/jobs_userland
ls $jenkins_userland_root/jobs_userland/*.xml 2> /dev/null
if [[ $? == 0 ]]; then
  printf "Creating User-Land Jobs ***************************************************************"
  ls $jenkins_userland_root/jobs_userland/*.xml | while read jenkins_xml_config; do
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
