#!/bin/bash --login
printf "Updating ssllabs-scan Dependencies..."
sudo apt-get install -y golang
echo "complete."


printf "Updating ssllabs-scan..."
ssllabs-scan_root="/opt/ssllabs-scan"
sudo /bin/bash --login -c "cd /opt && git pull && cd ${ssllabs-scan_root} && make && ln -sf ${ssllabs-scan_root}/ssllabs-scan /usr/bin/"
echo "complete."
