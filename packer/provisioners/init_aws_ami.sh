#!/bin/bash --login
# Begin Converting to Kali Rolling
sudo /bin/bash --login -c "DEBIAN_FRONTEND=noninteractive apt install -yq dirmngr software-properties-common"
sudo /bin/bash --login -c "> /etc/apt/sources.list && add-apt-repository 'deb https://http.kali.org/kali kali-rolling main non-free contrib' && echo 'deb-src https://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list"

# Download and import the official Kali Linux key
wget -q -O - https://www.kali.org/archive-key.asc | sudo apt-key add -

# Update our apt db so we can install kali-keyring
sudo apt update

# Install the Kali keyring
sudo /bin/bash --login -c "DEBIAN_FRONTEND=noninteractive apt install -yq kali-archive-keyring"

# Update our apt db again now that kali-keyring is installed
sudo apt update
