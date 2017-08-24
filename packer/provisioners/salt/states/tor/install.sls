{% set tor_pkgs = ['tor', 'tor-geoipdb', 'torsocks'] %}

install_tor_packages:
  pkg.installed:
    - pkgs: {{ tor_pkgs }}