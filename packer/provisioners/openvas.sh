#!/bin/bash --login
sudo apt install -y rpm alien nsis openvas redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo openvas-setup
sudo openvas-check-setup
# Add a working systemd daemon
sudo cp /csi/etc/systemd/openvas.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable openvas.service
sudo systemctl start openvas.service
# Symlink to folder containing NASL files
sudo ln -s /var/lib/openvas/plugins /opt/openvas_plugins
