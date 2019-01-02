#!/bin/bash
ssllabs_root="/opt/ssllabs-scan"
sudo apt install -y golang
sudo /bin/bash --login -c "cd /opt && git clone https://github.com/ssllabs/ssllabs-scan.git"
sudo /bin/bash --login -c "cd ${ssllabs_root} && make && ln -sf ${ssllabs_root}/ssllabs-scan-v3 /usr/local/bin/ssllabs-scan"
