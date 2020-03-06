#!/bin/bash --login
source /etc/profile.d/globals.sh

# PEDA - Python Exploit Development Assistance for GDB to be used w/ AFL
$screen_cmd "${apt} install -y libini-config-dev libseccomp-dev ${assess_update_errors}"
sudo /bin/bash --login -c 'cd /opt && git clone https://github.com/zardus/preeny preeny-dev && cd /opt/preeny-dev && make'
