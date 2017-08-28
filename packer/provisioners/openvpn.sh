#!/bin/bash --login
sudo apt install -y openvpn resolvconf
sudo systemctl enable resolvconf
sudo systemctl start resolvconf
