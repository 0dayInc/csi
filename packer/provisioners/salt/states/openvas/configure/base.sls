include:
  - openvas.install

openvas_unit_file:
  file.managed:
    - name: /etc/systemd/system/openvas.service
    - source: salt://openvas/files/openvas.service
    - backup: minion
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: install_openvas_packages

