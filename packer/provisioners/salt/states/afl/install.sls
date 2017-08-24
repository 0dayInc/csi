{% set afl_pkgs = ['afl', 'afl-clang', 'afl-cov', 'afl-doc'] %}

install_afl_packages:
  pkg.installed:
    - pkgs: {{ afl_pkgs }}