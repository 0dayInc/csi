#!/bin/bash --login
printf "Installing tor ************************************************************************"
sudo /bin/bash --login -c "apt-get install -y tor tor-geoipdb torsocks"
