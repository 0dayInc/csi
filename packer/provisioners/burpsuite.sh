#!/bin/bash --login

printf "Installing BurpBuddy API for Burpsuite *****************************************"
sudo apt install -y openjdk-8-jdk libgconf-2-4
curl --silent 'https://api.github.com/repos/tomsteele/burpbuddy/releases/latest' > /tmp/latest_burpbuddy.json
latest_burpbuddy_jar=$(ruby -e "require 'json'; pp JSON.parse(File.read('/tmp/latest_burpbuddy.json'), symbolize_names: true)[:assets][0][:browser_download_url]")
burpbuddy_jar_url=`echo ${latest_burpbuddy_jar} | sed 's/"//g'`
wget $burpbuddy_jar_url -P /tmp/
burp_root="/opt/burpsuite"
sudo /bin/bash --login -c "mkdir ${burp_root} && cp /tmp/burpbuddy*.jar ${burp_root} && cd ${burp_root} && ls burpbuddy*.jar | while read bb_latest; do ln -s ${bb_latest} burpbuddy.jar && rm /tmp/latest_burpbuddy.json && rm /tmp/burpbuddy*.jar"

# Config Free Version by Default...Burpsuite Pro Handled by Vagrant Provisioner & Userland Config
sudo cp /usr/bin/burpsuite /opt/burpsuite/burpsuite-kali-native.jar
