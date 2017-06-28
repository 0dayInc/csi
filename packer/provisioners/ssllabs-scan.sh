#!/bin/bash --login
printf "Installing ssllabs-scan ***************************************************************"
sudo apt-get install -y golang
ssllabs_root="/opt/ssllabs-scan"
sudo /bin/bash --login -c "cd /opt && git clone https://github.com/ssllabs/ssllabs-scan.git && cd ${ssllabs_root} && make && ln -sf ${ssllabs_root}/ssllabs-scan /usr/local/bin/"
