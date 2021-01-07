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

ls pkg/*.gem | while read previous_gems; do 
  rm $previous_gems
done
old_ruby_version=`cat ${csi_root}/.ruby-version`
# Default Strategy is to merge codebase
git config pull.rebase false 
git pull
new_ruby_version=`cat ${csi_root}/.ruby-version`

if [[ $old_ruby_version == $new_ruby_version ]]; then
  rvmsudo /bin/bash --login -c "cd ${csi_root} && ./reinstall_csi_gemset.sh"
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
