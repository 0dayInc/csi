#!/bin/bash --login
printf "Installing Dcoker ********************************************************************"
docker_sources='/etc/apt/sources.list.d/docker.list'
sudo /bin/bash --login -c "apt-get remove -y docker docker-engine docker.io*"
sudo /bin/bash --login -c "apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo bash --login -c "echo 'deb https://download.docker.com/linux/debian stretch stable' > ${docker_sources}"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker vagrant
sudo systemctl enable docker
