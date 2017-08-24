{% set openvas_pkgs = ['rpm', 'alien', 'nsis', 'openvas', 'redis-server'] %}

install_openvas_packages:
  pkg.installed:
    - pkgs: {{ openvas_pkgs }}