#!/bin/bash --login
sudo apt-get install -y rpm alien nsis openvas redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo openvas-setup
sudo openvas-check-setup
# Add a working systemd daemon
sudo cp /csi/etc/systemd/openvas.service /etc/systemd/system/
# We leverage Virtual Hosting w/in Apache2 to provide TLS connection
sudo sed -i '9s/.*/ExecStart=\/usr\/sbin\/gsad --foreground --listen=127\.0\.0\.1 --port=9392 --mlisten=127\.0\.0\.1 --mport=9390 --http-only --no-redirect/' /lib/systemd/system/greenbone-security-assistant.service
sudo systemctl daemon-reload
sudo systemctl enable openvas.service
sudo systemctl start openvas.service
# Symlink to folder containing NASL files
sudo ln -s /var/lib/openvas/plugins /opt/openvas_plugins
