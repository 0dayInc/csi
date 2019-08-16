#!/bin/bash --login
# Configure simple tasks to run @ boot

sudo /bin/bash --login -c 'echo "#!/bin/sh -e" > /etc/rc.local'

sudo /bin/bash --login -c 'echo "ifconfig lo:0 127.0.0.2 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'echo "ifconfig lo:1 127.0.0.3 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'echo "ifconfig lo:2 127.0.0.4 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'echo "sudo -H -u csi_admin /usr/local/bin/toggle_tor.sh" >> /etc/rc.local'

sudo /bin/bash --login -c 'echo "exit 0" >> /etc/rc.local'
sudo /bin/bash --login -c 'chmod 755 /etc/rc.local'
