#!/bin/bash --login
printf "Updating SQLMap Dependencies..."
sudo apt-get install -y python
echo "complete."

printf "Updating SQLMap..."
sudo /bin/bash --login -c "cd /opt/sqlmap-dev && git pull"
sudo ln -sf /opt/sqlmap-dev/sqlmap.py /usr/bin/
sudo ln -sf /opt/sqlmap-dev/sqlmapapi.py /usr/bin/
echo "complete."
