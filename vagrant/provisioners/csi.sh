#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then 
  csi_root='/csi'
else 
  csi_root="'${CSI_ROOT}'"
fi

sudo /bin/bash --login -c "cd ${csi_root} && ./reinstall_csi_gemset.sh"
sudo /bin/bash --login -c "cd ${csi_root} && ./build_csi_gem.sh"
