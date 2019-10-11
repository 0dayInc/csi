#!/bin/bash
# Initializes RVM for Normal Users
sudo /bin/bash --login -c 'echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc'
sudo /bin/bash --login -c 'echo "source /etc/profile.d/aliases.sh" >> /etc/bash.bashrc'
sudo /bin/bash --login -c 'echo "source /etc/profile.d/csi_envs.sh" >> /etc/bash.bashrc'
