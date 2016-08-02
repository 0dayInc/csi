#!/bin/bash
printf "Installing DNSRecon *******************************************************************"
dnsrecon_root="/opt/dnsrecon-git"
sudo -i /bin/bash --login -c "git clone https://github.com/darkoperator/dnsrecon.git ${dnsrecon_root} && cd ${dnsrecon_root} && pip install -r requirements.txt"
