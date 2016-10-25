#!/bin/bash --login
printf "Updating DNSRecon *********************************************************************"
sudo apt-get install -y python libavahi-compat-libdnssd1 git-core python-setuptools python-pip
sudo /bin/bash --login -c "cd /opt/dnsrecon-dev && git pull && pip install -r requirements.txt --upgrade"
