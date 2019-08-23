#!/bin/bash --login
sysmap='System.map-4.19.0-kali4-amd64'
config='config-4.19.0-kali4-amd64'
initrd='initrd.img-4.19.0-kali4-amd64'
kernel='vmlinuz-4.19.0-kali4-amd64'

sudo /bin/bash --login -c "mv /tmp/${sysmap} /boot && chmod 0644 /boot/${sysmap} && chown root:root /boot/${sysmap}"
sudo /bin/bash --login -c "mv /tmp/${config} /boot && chmod 0644 /boot/${config} && chown root:root /boot/${config}"
sudo /bin/bash --login -c "mv /tmp/${initrd} /boot && chmod 0644 /boot/${initrd} && chown root:root /boot/${initrd}"
sudo /bin/bash --login -c "mv /tmp/${kernel} /boot && chmod 0644 /boot/${kernel} && chown root:root /boot/${kernel}"
