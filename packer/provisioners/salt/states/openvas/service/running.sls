{% set services = ['redis-server', 'openvas'] %}

include:
  - openvas.install
  - openvas.configure

openvas:
  service.running:
    - name: 'openvas.service'
    - enable: True
    - require:
      - file: openvas_unit_file

redis-server:
  service.running:
    - name: 'redis-server'
    - enable: True
    - require:
      - pkg: install_openvas_packages
