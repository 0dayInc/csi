{%- set ruby_version = salt['cmd.run']('cat /csi/.ruby-version') -%}
{%- set domain_name = salt['cmd.run']('hostname -d') -%}
{%- set initial_admin_pwd = salt['cmd.run']('cat /var/lib/jenkins/secrets/initialAdminPassword') -%}
{%- set jenkins_pkgs = ['jenkins', 'openjdk-8-jdk', 'mongodb'] -%}
{%- set rvm_use = ruby_version + '@csi' -%}

source_rvm:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
    - shell: /bin/bash

set_env_ruby_version:
  environ.setenv:
    - name: ruby_version
    - value: {{ ruby_version }}

set_env_domain_name:
  environ.setenv:
    - name: domain_name
    - value: {{ domain_name }}

rvm_use_{{ ruby_version }}:
  cmd.run:
    - name: |
        rvm use {{ rvm_use }}

download_jenkins_key:
  file.managed:
    - name: /root/jenkins-ci.org.key
    - source: https://jenkins-ci.org/debian/jenkins-ci.org.key
    - source_hash: 9500ca61a5a755c2d3d5815e94142f6d

add_jenkins_key:
  cmd.run:
    - name: |
        apt-key add /root/jenkins-ci.org.key
    - shell: /bin/bash
    - require:
      - file: download_jenkins_key

jenkins_apt_source:
  file.managed:
    - name: /etc/apt/sources.list.d/jenkins.list
    - contents:
      - deb http://pkg.jenkins-ci.org/debian binary/

update_pkgs:
  pkg.uptodate:
    - refresh: True

jenkins_install_packages:
  pkg.installed:
    - pkgs: {{ jenkins_pkgs }}

copy_jenkins_default:
  file.copy:
    - name: /etc/default/jenkins
    - source: /csi/etc/jenkins/jenkins

jenkins_default_replace_domain:
  file.replace:
    - name: /etc/default/jenkins
    - pattern: |
        DOMAIN
    - repl: {{ domain_name }}

jenkins_add_sudo:
  user.present:
    - name: jenkins
    - groups: ['sudo']

jenkins_enable_service:
  service.running:
    - name: jenkins
    - enable: True
    - watch:
      - user: jenkins_add_sudo

jenkins_initialize:
  cmd.run:
    - name: |
        printf "Sleeping 99s While Jenkins Daemon Wakes Up ********************************************"
        ruby -e "(0..99).each { print '.'; sleep 1 }"
    - shell: /bin/bash

set_env_initial_admin_pwd:
  environ.setenv:
    - name: initial_admin_pwd
    - value: {{ initial_admin_pwd }}

jenkins_install_plugin:
  cmd.run:
    - name: |
        csi_jenkins_install_plugin --jenkins_ip 127.0.0.1 -U admin -P $initial_admin_pwd --no-restart-jenkins -p "ace-editor, amazon-ecs, analysis-core, ansible, ansicolor, ant, antisamy-markup-formatter, aws-beanstalk-publisher-plugin, aws-credentials, aws-java-sdk, brakeman, branch-api, bugzilla, bulk-builder, cloudbees-folder, compress-artifacts, config-autorefresh-plugin, configurationslicing, confluence-publisher, credentials, credentials-binding, cvs, dashboard-view, dependency-check-jenkins-plugin, discard-old-build, disk-usage, dropdown-viewstabbar-plugin, durable-task, email-ext, envinject, environment-script, extended-choice-parameter, extended-read-permission, external-monitor-job, fortify360, git, git-client, git-server, gitbucket, github, github-api, github-branch-source, github-organization-folder, gitlab-hook, gitlab-plugin, handlebars, htmlpublisher, http_request, icon-shim, image-gallery, jackson2-api, javadoc, jenkins-jira-issue-updater, jira, job-import-plugin, jquery, jquery-detached, junit, ldap, log-parser, mailer, mapdb-api, matrix-auth, matrix-project, maven-plugin, metrics, metrics-diskusage, momentjs, mongodb-document-upload, nested-view, pam-auth, parameterized-trigger, pipeline-build-step, pipeline-input-step, pipeline-rest-api, pipeline-stage-step, pipeline-stage-view, plain-credentials, purge-build-queue-plugin, role-strategy, ruby-runtime, saml, scm-api, script-security, slack, ssh-agent, ssh-credentials, ssh-slaves, structs, subversion, text-finder, thinBackup, token-macro, translation, windows-slaves, workflow-aggregator, workflow-api, workflow-basic-steps, workflow-cps, workflow-cps-global-lib, workflow-durable-task-step, workflow-job, workflow-multibranch, workflow-scm-step, workflow-step-api, workflow-support, ws-cleanup"
    - shell: /bin/bash
