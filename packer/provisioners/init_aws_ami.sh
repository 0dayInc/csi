#!/bin/bash --login
sysmap='System.map-4.19.0-kali4-amd64'
config='config-4.19.0-kali4-amd64'
initrd='initrd.img-4.19.0-kali4-amd64'
kernel='vmlinuz-4.19.0-kali4-amd64'
grub='/etc/default/grub'
grub_custom='/etc/grub.d/40_custom'

#sudo /bin/bash --login -c "mv /tmp/${sysmap} /boot && chmod 0644 /boot/${sysmap} && chown root:root /boot/${sysmap}"
#sudo /bin/bash --login -c "mv /tmp/${config} /boot && chmod 0644 /boot/${config} && chown root:root /boot/${config}"
#sudo /bin/bash --login -c "mv /tmp/${initrd} /boot && chmod 0644 /boot/${initrd} && chown root:root /boot/${initrd}"
#sudo /bin/bash --login -c "mv /tmp/${kernel} /boot && chmod 0644 /boot/${kernel} && chown root:root /boot/${kernel}"
sudo /bin/bash --login -c "ln -sf /boot/grub/grub.cfg /boot/grub/menu.lst"
sudo /bin/bash --login -c "mv /tmp/40_custom ${grub_custom} && chmod 0755 ${grub_custom} && chown root:root ${grub_custom} && update-grub2"
#sudo /bin/bash --login -c "mv /tmp/grub ${grub} && chmod 0644 ${grub} && chown root:root ${grub} && update-grub2"
