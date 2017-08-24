{%- set metasploit_root = '/opt/metasploit-framework-dev' -%}
{%- set metasploit_ruby_version = salt['cmd.run']('cat ' + metasploit_root + '/.ruby-version') -%}
{%- set metasploit_gemset = salt['cmd.run']('cat ' + metasploit_root + '/.ruby-gemset') -%}

metasploit_git_clone:
  git.latest:
    - name: https://github.com/rapid7/metasploit-framework.git
    - target: {{ metasploit_root }}
    - force_fetch: True

metasploiit_rvm_initial_setup:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
        rvm install ruby-{{ metasploit_ruby_version }}
        rvm use ruby-{{ metasploit_ruby_version }}
        rvm gemset create {{ metasploit_gemset }}
        cd {{ metasploit_root }} && gem install bundler && bundle install

metasploit_vagrant:
  file.managed:
    - name: /csi/etc/metasploit/vagrant.yaml
    - source: salt://metasploit/files/vagrant.yaml.EXAMPLE

metasploit_rvm_final_setup:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
        rvm use ruby-{{ metasploit_ruby_version }}@{{ metasploit_gemset }}

metasploit_service_unit_file:
  file.managed:
    - name: /etc/systemd/system/msfrpcd.service
    - source: salt://metasploit/files/msfrpcd.service

service.systemctl_reload:
  module.run:
    - onchanges:
      - file: metasploit_service_unit_file

metasploit_start_service:
  cmd.run:
    - name: |
        systemctl start msfrpcd
    - require:
      - file: metasploit_service_unit_file
