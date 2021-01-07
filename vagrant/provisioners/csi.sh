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

#sudo /bin/bash --login -c "cd ${csi_root} && ./reinstall_csi_gemset.sh"
#sudo /bin/bash --login -c "cd ${csi_root} && ./build_csi_gem.sh"
export rvmsudo_secure_path=1
rvmsudo /bin/bash --login -c "cd ${csi_root} && ./reinstall_csi_gemset.sh"
rvmsudo /bin/bash --login -c "cd ${csi_root} && ./build_csi_gem.sh"
