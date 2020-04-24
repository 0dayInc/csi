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

sudo systemctl enable postgresql
sudo systemctl restart postgresql
