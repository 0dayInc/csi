#!/bin/bash --login
echo 'Updating /etc/sudoers...'
echo 'vagrant ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/kalicsi
chmod 440 /etc/sudoers.d/kalicsi
