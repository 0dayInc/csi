#!/bin/bash
if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`
postgres_userland_root="${csi_root}/etc/userland/${csi_provider}/postgres"
postgres_vagrant_yaml="${postgres_userland_root}/vagrant.yaml"
user=`ruby -e "require 'yaml'; print YAML.load_file('${postgres_vagrant_yaml}')['user']"`
pass=`ruby -e "require 'yaml'; print YAML.load_file('${postgres_vagrant_yaml}')['pass']"`
create_user_cmd=$(cat << EOF
  create user ${user}
  with password '${pass}';
EOF
)
sudo /bin/bash --login -c "echo ${create_user_cmd} | sudo -iu postgres psql"
