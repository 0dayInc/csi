#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

rm pkg/*.gem
old_ruby_version=`cat ${csi_root}/.ruby-version`
git pull
new_ruby_version=`cat ${csi_root}/.ruby-version`

if [[ $old_ruby_version == $new_ruby_version ]]; then
  rvmsudo rake
  rvmsudo rake install
  rvmsudo rake rerdoc
  rvmsudo gem update --system
  rvmsudo gem rdoc --rdoc --ri --overwrite -V csi
  echo "Invoking bundle-audit Gemfile Scanner..."
  rvmsudo bundle-audit
else
  cd $csi_root && ./upgrade_ruby.sh $new_ruby_version $old_ruby_version
fi
