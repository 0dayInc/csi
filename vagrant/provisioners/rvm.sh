#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  csi_root='/csi'
else
  csi_root="${CSI_ROOT}"
fi

ruby_version=`cat ${csi_root}/.ruby-version`
ruby_gemset=`cat ${csi_root}/.ruby-gemset`
printf "Updating RVM..."
rvm get latest
rvm reload
/bin/bash --login -c "source /etc/profile.d/rvm.sh && rvm --default ruby-${ruby_version}@${ruby_gemset}"
echo "complete."
