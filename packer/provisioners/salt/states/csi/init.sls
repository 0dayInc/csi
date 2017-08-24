{% set csi_pkgs = ['wget', 'fontconfig', 'postgresql-server-dev-all', 'libpcap-dev', 'libsndfile1', 'libsndfile-dev', 'imagemagick', 'libmagickwand-dev', 'tesseract-ocr-all'] %}

install_csi_packages:
  pkg.installed:
    - pkgs: {{ csi_pkgs }}

tesseract_trained_data:
  file.managed:
    - name: /usr/share/tesseract-ocr/eng.traineddata
    - source: https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata
    - source_hash: 7af2ad02d11702c7092a5f8dd044d52f
    - makedirs: True

copy_metasploit_yaml:
  file.managed:
    - name: /etc/metasploit/vagrant.yaml
    - source: /etc/metasploit/vagrant.yaml.EXAMPLE

reinstall_csi_gemset:
  cmd.script:
    - source: salt://csi/files/reinstall_csi_gemset.sh
    - cwd: /csi

build_csi_gem:
  cmd.script:
    - source: salt://csi/files/build_csi_gem.sh
    - cwd: /csi
    - require:
      - cmd: reinstall_csi_gemset

rubocop:
  cmd.script:
    - source: salt://csi/files/rubocop.sh
    - cwd: /csi
    - require:
      - cmd: build_csi_gem
