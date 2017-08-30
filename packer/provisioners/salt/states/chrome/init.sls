{% set chrome_pkgs = ['chromium', 'chromium-driver'] %}

install_chrome_pkgs:
  pkg.installed:
    - pkgs: {{ chrome_pkgs }}