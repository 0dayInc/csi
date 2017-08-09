#!/bin/bash --login

printf "Installing Custom BurpBuddy API for Burpsuite *****************************************"
sudo apt-get install -y openjdk-8-jdk maven
burpbuddy_tp_root="/csi/third_party/burpbuddy"
burp_root="/opt/burpsuite"
burpbuddy_build_root="${burp_root}/burpbuddy/burp"
sudo /bin/bash --login -c "mkdir ${burp_root} && cp -a ${burpbuddy_tp_root} ${burp_root} && cd ${burpbuddy_build_root} && mvn package && cp ${burpbuddy_build_root}/target/burpbuddy-2.3.1.jar ${burp_root}"

sudo /bin/bash --login -c 'echo "ifconfig lo:0 127.0.0.2 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'echo "ifconfig lo:0 127.0.0.3 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'echo "ifconfig lo:0 127.0.0.4 netmask 255.0.0.0 up" >> /etc/rc.local'
sudo /bin/bash --login -c 'chmod 755 /etc/rc.local'

#TODO: Install Burpsuite Pro? (May need to rely upon end-user to do this)
