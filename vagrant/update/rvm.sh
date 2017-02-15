#!/bin/bash --login
ruby_version=`cat /csi/.ruby-version`
ruby_gemset=`cat /csi/.ruby-gemset`
printf "Updating RVM..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
rvm get latest
rvm reload
/bin/bash --login -c "source /etc/profile.d/rvm.sh && rvm --default ${ruby_version}@${ruby_gemset}"
echo "complete."
