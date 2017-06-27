#!/bin/bash --login
sudo /bin/bash --login -c 'apt-get install -y rpm alien nsis openvas && openvas-setup && openvas-check-setup && /etc/init.d/openvas-manager start && /etc/init.d/greenbone-security-assistant start'
