{%- set beef_ruby_version = salt['cmd.run']('cat /opt/wpscan-dev/.ruby-version') -%}
{%- set beef_gemset = salt['cmd.run']('cat /opt/wpscan-dev/.ruby-gemset') -%}

beef_git_clone:
  git.latest:
    - name: https://github.com/beefproject/beef.git beef-dev
    - target: {{ beef_root }}
    - force_fetch: True

checkout_wpscan:
  git.latest:
    - name: https://github.com/wpscanteam/wpscan.git
    - target: /opt/wpscan-dev
    - branch: master

beef_source_rvm:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
    - shell: /bin/bash

beef_rvm_tasks:
  cmd.run:
    - name: |
        rvm install ruby-{{ beef_ruby_version }}
        rvm use ruby-{{ beef_ruby_version }}
        rvm gemset create {{ beef_gemset }}
        rvm use ruby-{{ beef_ruby_version }}@{{ beef_gemset }}
        gem install bundler
        bundle install
    - cwd: /opt/beef-dev
    - shell: /bin/bash