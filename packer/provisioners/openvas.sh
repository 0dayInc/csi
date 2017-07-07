#!/bin/bash --login
sudo apt-get install -y rpm alien nsis openvas redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo openvas-setup
sudo openvas-check-setup
# Add a working systemd daemon
sudo cp /csi/etc/systemd/openvas.service /etc/systemd/system/
sudo systemctl enable openvas
sudo systemctl start openvas
