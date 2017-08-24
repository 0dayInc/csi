rvm_install_gnupg2:
  pkg.installed:
    - name: gnupg2

rvm_download_mpapis_key:
  file.managed:
    - name: /tmp/mpapis.asc
    - source: https://rvm.io/mpapis.asc
    - source_hash: md5=b9bc3b9e609f42c3a8e1af3cbd2da3b0
    - require:
      - pip: rvm_install_gnupg

rvm_install_gnupg:
  pip.installed:
    - name: gnupg

rvm_gpg_import_mpapis_key:
  module.run:
    - name: gpg.import_key
    - kwargs:
        filename: /tmp/mpapis.asc
        user: root
    - require:
      - file: rvm_download_mpapis_key

rvm_gpg_trust_key:
  cmd.run:
    - name: |
        echo -e "trust\n5\ny\n" | gpg2 --command-fd 0 --edit-key 409B6B1796C275462A1703113804BB82D39DC0E3
    - require:
      - module: rvm_gpg_import_mpapis_key

rvm_install:
  module.run:
    - name: rvm.install
