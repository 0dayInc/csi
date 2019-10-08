#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  csi_root='/csi'
else
  csi_root="${CSI_ROOT}"
fi

rm pkg/*.gem
old_ruby_version=`cat ${csi_root}/.ruby-version`
git pull
new_ruby_version=`cat ${csi_root}/.ruby-version`

if [[ $old_ruby_version == $new_ruby_version ]]; then
  rake
  rake install
  rake rerdoc
  gem rdoc --rdoc --ri --overwrite -V csi
  bundle update
  bundle-audit update
  echo "Invoking bundle-audit Gemfile Scanner..."
  bundle-audit
else
  cd $csi_root && ./upgrade_ruby.sh $new_ruby_version $old_ruby_version
fi
