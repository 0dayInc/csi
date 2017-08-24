{% set ruby_pkgs = ['build-essential', 'bison', 'openssl', 'libreadline-dev', 'curl', 'git-core', 'git', 'zlib1g', 'zlib1g-dev', 'libssl-dev', 'libyaml-dev', 'libxml2-dev', 'autoconf', 'libc6-dev', 'ncurses-dev', 'automake', 'libtool', 'libpcap-dev', 'libsqlite3-dev', 'libgmp-dev'] %}
{% set ruby_version = salt['cmd.run']('cat /csi/.ruby-version') %}
{% set ruby_gemset = salt['cmd.run']('cat /csi/.ruby-gemset') %}

ruby_install_packages:
  pkg.installed:
    - pkgs: {{ ruby_pkgs }}

ruby_clone_csi:
  git.latest:
    - name: https://github.com/ninp0/csi.git
    - target: /csi

ruby_source_rvm:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh

ruby_rvm_install_{{ ruby_version }}:
  rvm.installed:
    - name: {{ ruby_version }}
