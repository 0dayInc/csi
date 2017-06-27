#!/bin/bash --login
printf "Installing SQLMap *********************************************************************"
sudo apt-get install -y python
cd /opt && sudo git clone https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
sudo ln -s /opt/sqlmap-dev/sqlmap.py /usr/bin/
sudo ln -s /opt/sqlmap-dev/sqlmapapi.py /usr/bin/
