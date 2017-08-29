{%- set openvpn_pkgs = ['openvpn', 'resolvconf'] -%}

install_openvpn_pkgs:
  pkg.installed:
    - pkgs: openvpn_pkgs

resolvconf_service:
  service.running:
    - name: resolvconf
    - enable: True