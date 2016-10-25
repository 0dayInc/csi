#!/bin/bash --login
printf "Updating ssllabs-scan Dependencies..."
sudo apt-get install -y golang
echo "complete."


printf "Updating ssllabs-scan..."
ssllabsscan_root="/opt/ssllabs-scan"
sudo /bin/bash --login -c "cd /opt && git pull && cd ${ssllabsscan_root} && make && ln -sf ${ssllabsscan_root}/ssllabs-scan /usr/bin/"
echo "complete."
