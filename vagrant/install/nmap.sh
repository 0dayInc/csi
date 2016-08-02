#!/bin/bash --login
printf "Installing Nmap ***********************************************************************"
sudo apt-get install -y subversion hping3 p0f dsniff
sudo /bin/bash --login -c "cd /opt && svn co https://svn.nmap.org/nmap nmap-dev && cd /opt/nmap-dev && ./configure && make && make install"
