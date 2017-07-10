#!/bin/bash --login
# Make sure the csi gemset has been loaded
source /etc/profile.d/rvm.sh
ruby_version=`cat /csi/.ruby-version`
rvm use $ruby_version@csi

printf "Installing Jenkins ********************************************************************"
domain_name=`hostname -d`
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins openjdk-8-jdk mongodb
sudo /bin/bash --login -c "cp /csi/etc/jenkins/jenkins /etc/default/jenkins"
sudo /bin/bash --login -c "sed -i \"s/DOMAIN/${domain_name}/g\" /etc/default/jenkins" 
sudo /etc/init.d/jenkins restart

printf "Sleeping 99s While Jenkins Daemon Wakes Up ********************************************"
ruby -e "(0..99).each { print '.'; sleep 1 }"

initial_admin_pwd=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# TODO: Get this working
# printf "Creating User *************************************************************************"
# new_user=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['user']"`
# new_pass=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/jenkins/vagrant.yaml')['pass']"`
# csi_jenkins_useradd --jenkins_ip 127.0.0.1 -u $new_user -p $new_pass -U admin -P $initial_admin_pwd

# TODO: Get this working
# printf "Updating Pre-Installed Jenkins Plugins ************************************************"
# csi_jenkins_update_plugins --jenkins_ip 127.0.0.1 -U admin -P $initial_admin_pwd --no-restart-jenkins

printf "Installing Necessary Jenkins Plugins **************************************************"
csi_jenkins_install_plugin --jenkins_ip 127.0.0.1 -U admin -P $initial_admin_pwd --no-restart-jenkins -p "ace-editor, amazon-ecs, analysis-core, ansible, ansicolor, ant, antisamy-markup-formatter, aws-beanstalk-publisher-plugin, aws-credentials, aws-java-sdk, brakeman, branch-api, bugzilla, bulk-builder, cloudbees-folder, compress-artifacts, config-autorefresh-plugin, configurationslicing, confluence-publisher, credentials, credentials-binding, cvs, dashboard-view, dependency-check-jenkins-plugin, discard-old-build, disk-usage, dropdown-viewstabbar-plugin, durable-task, email-ext, envinject, environment-script, extended-choice-parameter, extended-read-permission, external-monitor-job, fortify360, git, git-client, git-server, gitbucket, github, github-api, github-branch-source, github-organization-folder, gitlab-hook, gitlab-plugin, handlebars, htmlpublisher, http_request, icon-shim, image-gallery, jackson2-api, javadoc, jenkins-jira-issue-updater, jira, job-import-plugin, jquery, jquery-detached, junit, ldap, log-parser, mailer, mapdb-api, matrix-auth, matrix-project, maven-plugin, metrics, metrics-diskusage, momentjs, mongodb-document-upload, nested-view, pam-auth, parameterized-trigger, pipeline-build-step, pipeline-input-step, pipeline-rest-api, pipeline-stage-step, pipeline-stage-view, plain-credentials, purge-build-queue-plugin, role-strategy, ruby-runtime, saml, scm-api, script-security, shared-objects, slack, ssh-agent, ssh-credentials, ssh-slaves, structs, subversion, text-finder, thinBackup, token-macro, translation, windows-slaves, workflow-aggregator, workflow-api, workflow-basic-steps, workflow-cps, workflow-cps-global-lib, workflow-durable-task-step, workflow-job, workflow-multibranch, workflow-scm-step, workflow-step-api, workflow-support, ws-cleanup"
