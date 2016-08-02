#!/bin/bash --login
printf "Installing SSLyze *********************************************************************"
sudo apt-get install -y python python-pip
sslyze_root="/opt/sslyze-dev"
sudo /bin/bash --login -c "cd /opt && git clone https://github.com/nabla-c0d3/sslyze.git sslyze-dev && cd ${sslyze_root} && pip install -r requirements.txt --target ./lib"
