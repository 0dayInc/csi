#!/bin/bash --login
ruby_version=$(cat /csi/.ruby-version)
ruby_gemset=$(cat /csi/.ruby-gemset)
printf "Updating RVM..."
rvm get latest
rvm reload
/bin/bash --login -c "source /etc/profile.d/rvm.sh && rvm --default ruby-${ruby_version}@${ruby_gemset}"
echo "complete."
