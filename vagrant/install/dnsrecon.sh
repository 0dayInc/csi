#!/bin/bash --login
printf "Installing DNSRecon *******************************************************************"
sudo apt-get install -y python libavahi-compat-libdnssd1 git-core python-setuptools python-pip
sudo /bin/bash --login -c "cd /opt && git clone https://github.com/darkoperator/dnsrecon.git dnsrecon-dev && cd /opt/dnsrecon-dev && pip install -r requirements.txt"
