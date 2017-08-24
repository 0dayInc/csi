#!/bin/bash --login
sudo apt-get install -y openvpn resolvconf
sudo systemctl enable resolvconf
sudo systemctl start resolvconf
