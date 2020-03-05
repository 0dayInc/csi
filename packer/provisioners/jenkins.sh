#!/bin/bash --login
source /etc/profile.d/globals.sh

if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`

# Make sure the csi gemset has been loaded
source /etc/profile.d/rvm.sh
ruby_version=$(cat ${csi_root}/.ruby-version)
rvm use ruby-$ruby_version@csi

printf "Installing Jenkins ********************************************************************"
domain_name=`hostname -d`
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
# wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
# sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
# Get back to a Java version Jenkins supports (Temporarily 2018-04-19)
sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/bin/java /etc/alternatives/java
sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo /bin/bash --login -c "DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -yq jenkins openjdk-8-jdk"
sleep 9
sudo /bin/bash --login -c "cp ${csi_root}/etc/userland/$csi_provider/jenkins/jenkins /etc/default/jenkins"
sudo /bin/bash --login -c "sed -i \"s/DOMAIN/${domain_name}/g\" /etc/default/jenkins" 
sudo usermod -a -G sudo jenkins
sudo /bin/bash --login -c 'echo "jenkins ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins'
sudo systemctl enable jenkins
sudo systemctl restart jenkins

printf "Sleeping 540s While Jenkins Daemon Wakes Up ********************************************"
ruby -e "(0..540).each { print '.'; sleep 1 }"

initial_admin_pwd=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
echo "JENKINS Initial Admin: ${initial_admin_pwd}"

# TODO: Get this working
# printf "Updating Pre-Installed Jenkins Plugins ************************************************"
# csi_jenkins_update_plugins --jenkins_ip 127.0.0.1 -U admin -P $initial_admin_pwd --no-restart-jenkins

printf "Installing Necessary Jenkins Plugins **************************************************"
csi_jenkins_install_plugin --jenkins_ip 127.0.0.1 \
  -d 8888 \
  -U admin \
  -P $initial_admin_pwd \
  --no-restart-jenkins \
  -p "ace-editor, analysis-core, ansicolor, ant, antisamy-markup-formatter, apache-httpcomponents-client-4-api, bouncycastle-api, build-pipeline-plugin, bulk-builder, command-launcher, conditional-buildstep, credentials, dashboard-view, dependency-check-jenkins-plugin, dependency-track, display-url-api, external-monitor-job, git, git-client, handlebars, htmlpublisher, jackson2-api, javadoc, jdk-tool, jquery, jquery-detached, jquery-ui, jsch, junit, ldap, log-parser, mailer, matrix-auth, matrix-project, maven-plugin, momentjs, nested-view, pam-auth, parameterized-trigger, pipeline-build-step, pipeline-graph-analysis, pipeline-input-step, pipeline-rest-api, pipeline-stage-step, pipeline-stage-view, plain-credentials, purge-build-queue-plugin, role-strategy, run-condition, scm-api, script-security, slack, ssh-agent, ssh-credentials, ssh-slaves, structs, token-macro, windows-slaves, workflow-api, workflow-cps, workflow-job, workflow-scm-step, workflow-step-api, workflow-support"

  # -p "ansicolor, bulk-builder, dashboard-view, dependency-check-jenkins-plugin, git, htmlpublisher, log-parser, matrix-auth, matrix-project, nested-view, pipeline-build-step, pipeline-input-step, pipeline-rest-api, pipeline-stage-step, pipeline-stage-view, purge-build-queue-plugin, role-strategy, slack, ssh-agent, ssh-credentials, ssh-slaves"

  #-p "ace-editor, amazon-ecs, analysis-core, ansible, ansicolor, ant, antisamy-markup-formatter, aws-beanstalk-publisher-plugin, aws-credentials, aws-java-sdk, brakeman, branch-api, bulk-builder, cloudbees-folder, compress-artifacts, config-autorefresh-plugin, configurationslicing, confluence-publisher, credentials, credentials-binding, cvs, dashboard-view, dependency-check-jenkins-plugin, discard-old-build, disk-usage, dropdown-viewstabbar-plugin, durable-task, email-ext, envinject, environment-script, extended-choice-parameter, extended-read-permission, external-monitor-job, git, git-client, git-server, gitbucket, github, github-api, github-branch-source, github-organization-folder, handlebars, htmlpublisher, http_request, icon-shim, image-gallery, jackson2-api, javadoc, jenkins-jira-issue-updater, jira, job-import-plugin, jquery, jquery-detached, junit, ldap, log-parser, mailer, mapdb-api, matrix-auth, matrix-project, maven-plugin, metrics, metrics-diskusage, momentjs, nested-view, pam-auth, parameterized-trigger, pipeline-build-step, pipeline-input-step, pipeline-rest-api, pipeline-stage-step, pipeline-stage-view, plain-credentials, purge-build-queue-plugin, role-strategy, ruby-runtime, saml, scm-api, script-security, slack, ssh-agent, ssh-credentials, ssh-slaves, structs, subversion, text-finder, thinBackup, token-macro, translation, windows-slaves, workflow-aggregator, workflow-api, workflow-basic-steps, workflow-cps, workflow-cps-global-lib, workflow-durable-task-step, workflow-job, workflow-multibranch, workflow-scm-step, workflow-step-api, workflow-support, ws-cleanup"
