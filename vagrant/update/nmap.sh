#!/bin/bash --login
printf "Updating Nmap..."
sudo apt-get install -y subversion hping3 p0f dsniff
sudo /bin/bash --login -c "cd /opt/nmap-dev && svn up && ./configure && make && make install"
echo "complete."
