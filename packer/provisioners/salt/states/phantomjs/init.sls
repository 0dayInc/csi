phantomjs_download_and_install:
  cmd.script:
    - source: salt://phantomjs/files/phantomjs.rb
    - require:
      - cmd: phantomjs_rvm_setup

phantomjs_rvm_setup:
  cmd.run:
    - name: |
        source /etc/profile.d/rvm.sh
        ruby_version=`cat /csi/.ruby-version`
        rvm use $ruby_version@csi
