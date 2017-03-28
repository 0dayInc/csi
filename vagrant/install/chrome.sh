#!/bin/bash --login

printf "Installing Google Chrome **************************************************************"
sudo /bin/bash --login -c "apt-get install -y chromium-browser unzip && cd /csi/third_party && unzip chromedriver_linux64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/chromedriver"
