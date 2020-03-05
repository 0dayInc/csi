#!/bin/bash --login
source /etc/profile.d/globals.sh

printf "Installing Docker ********************************************************************"
docker_sources='/etc/apt/sources.list.d/docker.list'
$screen_cmd "${apt} remove -y docker docker-engine docker.io* ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y apt-transport-https ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y ca-certificates ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y curl ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y gnupg2 ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y software-properties-common ${assess_update_errors}"
grok_error

$screen_cmd "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - ${assess_update_errors}"
grok_error

$screen_cmd "echo 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' > ${docker_sources}"
grok_error

$screen_cmd "${apt} update ${assess_update_errors}"
grok_error

$screen_cmd "${apt} install -y docker-ce docker-compose ${assess_update_errors}"
grok_error

$screen_cmd "usermod -aG docker vagrant ${assess_update_errors}"
grok_error

$screen_cmd "systemctl enable docker ${assess_update_errors}"
grok_error
