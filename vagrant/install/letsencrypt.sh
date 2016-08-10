#!/bin/bash
printf "Installing Let's Encrypt **************************************************************"
letsencrypt_root="/opt/letsencrypt-git"
domain_name=`hostname -d`
#TODO: Figure out how to either A. leverage letsencrypt w/ <domain>.local as the domain or B. auto-enroll host w/ AWS Route53 :-/
sudo -i /bin/bash --login -c "git clone https://github.com/letsencrypt/letsencrypt ${letsencrypt_root} && cd ${letsencrypt_root} && ./letsencrypt-auto --non-interactive --agree-tos --text --apache -d csi.$domain_name -d openvas.$domain_name -d scapm.$domain_name --register-unsafely-without-email"
