{%- set wpscan_ruby_version = salt['cmd.run']('cat /opt/wpscan-dev/.ruby-version') -%}
{%- set wpscan_gemset = salt['cmd.run']('cat /opt/wpscan-dev/.ruby-gemset') -%}
{%- set wpscan_pkgs = ['libcurl4-gnutls-dev'] -%}

checkout_wpscan:
  git.latest:
    - name: https://github.com/wpscanteam/wpscan.git
    - target: /opt/wpscan-dev
    - branch: master

wpscan_pkgs:
  pkg.installed:
    - pkgs: {{ wpscan_pkgs }}

wpscan_source_rvm:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
    - shell: /bin/bash

wpscan_rvm_tasks:
  cmd.run:
    - name: |
        rvm install ruby-{{ wpscan_ruby_version }}
        rvm use ruby-{{ wpscan_ruby_version }}
        rvm gemset create {{ wpscan_gemset }}
        rvm use ruby-{{ wpscan_ruby_version }}@{{ wpscan_gemset }}
        gem install bundler
        bundle install --without test
    - cwd: /opt/wpscan-dev
    - shell: /bin/bash
