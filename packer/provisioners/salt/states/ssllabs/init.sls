set_env_ssllabs_root:
  environ.setenv:
    - name: ssllabs_root
    - value: /opt/ssllabs-scan

golang:
  pkg.installed:
    - name: golang

checkout_ssllabs-scan:
  git.latest:
    - name: https://github.com/ssllabs/ssllabs-scan.git
    - target: '/opt/ssllabs-scan'
    - branch: master
    - force_clone: True
    - require:
      - pkg: golang

install_ssllabs-scan:
  cmd.run:
    - name: |
        cd /opt/ssllabs-scan && make

create_ssllabs-scan_symlink:
  file.symlink:
    - name: /usr/local/bin/ssllabs-scan
    - target: /opt/ssllabs-scan/ssllabs-scan
    - force: True
    - require:
      - git: checkout_ssllabs-scan
