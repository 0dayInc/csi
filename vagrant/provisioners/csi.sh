#!/bin/bash --login
sudo /bin/bash --login -c 'cd /csi && ./reinstall_csi_gemset.sh'
sudo /bin/bash --login -c 'cd /csi && ./build_csi_gem.sh'
