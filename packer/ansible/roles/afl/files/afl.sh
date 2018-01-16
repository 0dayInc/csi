#!/bin/bash --login
# Build from source in order to support Qemu Instrumentation:
# Found in https://github.com/mirrorer/afl/README.md => "4) Instrumenting binary-only apps"
sudo apt install -y libtool libtool-bin libglib2.0-dev
sudo /bin/bash --login -c 'cd /opt && git clone https://github.com/mirrorer/afl afl-dev && cd /opt/afl-dev && make && cd /opt/afl-dev/qemu_mode && ./build_qemu_support.sh'

ls -l /opt/afl-dev | grep '^-rwx' | awk '{print $9}' | while read afl_bin; do 
  sudo ln -s /opt/afl-dev/$afl_bin /usr/local/bin/
done
