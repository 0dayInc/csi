#!/bin/bash
# Initializes RVM for Normal Users
sudo echo 'source /etc/profile.d/rvm.sh' >> /etc/bash.bashrc

# Used for proper phantomjs operation
sudo echo 'export QT_QPA_PLATFORM=minimal' >> /etc/bash.bashrc
