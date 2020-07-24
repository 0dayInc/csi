#!/bin/bash --login
source /etc/profile.d/globals.sh

# Build from source in order to support Qemu Instrumentation:
# Found in https://github.com/mirrorer/afl/README.md => "4) Instrumenting binary-only apps"
$screen_cmd "${apt} install -y libtool libtool-bin automake bison libglib2.0-dev qemu"
grok_error

$screen_cmd "cd /opt && git clone https://github.com/mirrorer/afl afl-dev && cd /opt/afl-dev && make && cd /opt/afl-dev/qemu_mode && ./build_qemu_support.sh"
grok_error

ls -l /opt/afl-dev | grep '^-rwx' | awk '{print $9}' | while read afl_bin; do 
  sudo ln -sf /opt/afl-dev/$afl_bin /usr/local/bin/
done
