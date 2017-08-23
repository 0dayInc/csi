#!/bin/bash --login
sudo -H -u vagrant /bin/bash --login -c 'cd /csi && ./reinstall_csi_gemset.sh && ./build_csi_gem.sh'
