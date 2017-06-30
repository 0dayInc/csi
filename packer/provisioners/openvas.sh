#!/bin/bash --login
sudo apt-get install -y rpm alien nsis openvas redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo openvas-setup
sudo openvas-check-setup
sudo update-rc.d openvas-manager defaults
sudo /etc/init.d/openvas-manager start
sudo update-rc.d greenbone-security-assistant defaults
sudo /etc/init.d/greenbone-security-assistant start'
