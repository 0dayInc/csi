#!/bin/bash --login
system_map='/tmp/System.map-4.19.0-kali4-amd64'
config='/tmp/config-4.19.0-kali4-amd64'
initrd='/tmp/initrd.img-4.19.0-kali4-amd64'
kernel='/tmp/vmlinuz-4.19.0-kali4-amd64'

sudo /bin/bash --login -c "mv ${system_map} /boot && chmod 0644 ${system_map} && chown root:root ${system_map}"
sudo /bin/bash --login -c "mv ${config} /boot && chmod 0644 ${config} && chown root:root ${config}"
sudo /bin/bash --login -c "mv ${initrd} /boot && chmod 0644 ${initrd} && chown root:root ${initrd}"
sudo /bin/bash --login -c "mv ${kernel} /boot && chmod 0644 ${kernel} && chown root:root ${kernel}"
