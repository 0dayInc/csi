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

date -u +%Y-%m-%d_%H.%M.%S
debug=$2
csi_deploy_type=$1
os=$(uname -s)

# TODO: Check that all configs exist
# MAKE .EXAMPLE and actual file the same
# if they're the same size prompt user to 
# configure
# TODO: install ansible in this script if not installed
# to take advantage of encrypted configs early on

function usage() {
  echo $"Usage: $0 <aws | docker_csi_prototyper | docker_csi_fuzz_net_app_proto | docker_csi_transparent_browser | docker_csi_scapm | docker_csi_www_checkip | ruby-gem | virtualbox | virtualbox-gui | vmware-fusion | vmware-fusion-gui | vmware-workstation | vmware-workstation-gui | vsphere>"
  date -u +%Y-%m-%d_%H.%M.%S
  exit 1
}

function deploy_docker_container() {
  export CSI_PROVIDER="docker"
  
  if [[ $debug == '' ]]; then
    vagrant up --provider=docker
  else
    vagrant up --provider=docker --debug
  fi

}

if [[ $# != 1  ]] && [[ $# != 2 ]]; then
  usage
fi

case $csi_deploy_type in
  "aws") 
    export CSI_PROVIDER="aws"
    if [[ -e "./etc/userland/aws/vagrant.yaml" ]]; then
      vagrant plugin install vagrant-reload
      vagrant plugin install vagrant-aws
      vagrant plugin install vagrant-aws-dns
      vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box --force
      if [[ $debug == '' ]]; then
        vagrant up --provider=aws
      else
        vagrant up --provider=aws --debug
      fi
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/userland/aws/vagrant.yaml.EXAMPLE as a Template to Create ./etc/userland/aws/vagrant.yaml"
    fi
    ;;
  "kvm")
    # TODO: Coming soon
    echo "Coming soon..."
    ;;
  "docker_csi_prototyper")
    export DOCKER_CONTAINER_TARGET="docker_csi_prototyper"
    deploy_docker_container
    ;;
  "docker_csi_fuzz_net_app_proto")
    export DOCKER_CONTAINER_TARGET="docker_csi_fuzz_net_app_proto"
    deploy_docker_container
    ;;
  "docker_csi_transparent_browser")
    export DOCKER_CONTAINER_TARGET="docker_csi_transparent_browser"
    deploy_docker_container
    ;;
  "docker_csi_scapm")
    export DOCKER_CONTAINER_TARGET="docker_csi_scapm"
    deploy_docker_container
    ;;
  "docker_csi_www_checkip")
    export DOCKER_CONTAINER_TARGET="docker_csi_www_checkip"
    deploy_docker_container
    ;;
  "ruby-gem")
    export CSI_PROVIDER="ruby-gem"
    ./packer/provisioners/rvm.sh
    ./packer/provisioners/ruby.sh
    ./packer/provisioners/csi.sh
    ;;
  "virtualbox"|"virtualbox-gui")
    if [[ -e "./etc/userland/virtualbox/vagrant.yaml" ]]; then
      export CSI_PROVIDER="virtualbox"
      if [[ $csi_deploy_type == "virtualbox-gui" ]]; then
        export VAGRANT_GUI="true"
      fi
      if [[ $debug == '' ]]; then
        vagrant up --provider=virtualbox
      else
        vagrant up --provider=virtualbox --debug
      fi
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/userland/virtualbox/vagrant.yaml.EXAMPLE as a Template to Create ./etc/userland/virtualbox/vagrant.yaml"
    fi
    ;;
  "vmware-fusion"|"vmware-fusion-gui"|"vmware-workstation"|"vmware-workstation-gui")
    if [[ -e "./etc/userland/vmware/vagrant.yaml" ]]; then
      export CSI_PROVIDER="vmware"
      license_file=$(ruby -e "require 'yaml'; print YAML.load_file('./etc/userland/vmware/vagrant.yaml')['vagrant_vmware_license']")
      vagrant plugin install vagrant-vmware-desktop
      vagrant plugin license vagrant-vmware-desktop $license_file
      
      case $csi_deploy_type in
        "vmware-fusion"|"vmware-fusion-gui")
          if [[ $csi_deploy_type == "vmware-fusion-gui" ]]; then
            export VAGRANT_GUI="true"
          fi

          if [[ $debug == '' ]]; then
            vagrant up --provider=vmware_fusion
          else
            vagrant up --provider=vmware_fusion --debug
          fi
          ;;
        "vmware-workstation"|"vmware-workstation-gui")
          if [[ $csi_deploy_type == "vmware-workstation-gui" ]]; then
            export VAGRANT_GUI="true"
          fi

          if [[ $debug == '' ]]; then
            vagrant up --provider=vmware_workstation
          else
            vagrant up --provider=vmware_workstation --debug
          fi
          ;;        
      esac
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/userland/vmware/vagrant.yaml.EXAMPLE as a Template to Create ./etc/userland/vmware/vagrant.yaml"
    fi
    ;;
  "vsphere")
    export CSI_PROVIDER="vmware"
    vmx=$(find ${csi_root}/.vagrant/machines/default/ -name packer-vmware-iso.vmx | grep vmware)
    if [[ -e $vmx ]]; then
      vagrant status | grep running
      if [[ $? == 0 ]]; then
        vagrant halt
      fi
      vmx_basename=$(basename $vmx)
      ova="$HOME/${vmx_basename}.ova"
      ovftool $vmx $ova
      if [[ $? == 0 ]]; then
        echo "vSphere Image: ${ova}"
        echo "Ready for deployment."
      else
        echo "There was an issue with the ovftool command."
        echo "Ensure the VM is powered down and ovftool is in your path (i.e. Symlink to /usr/local/bin)"
      fi
    else
      echo "ERROR: VMware VMX file for CSI is missing."
      echo "HINTS: Before running ${0} vsphere"
      echo "Run one of the following to deploy the local VMX necessary to create the vSphere OVA file:"
      echo "${0} vmware-fusion"
      echo "${0} vmware-fusion-gui"
      echo "${0} vmware-workstation"
      echo "${0} vmware-workstation-gui"
      echo -e "Implement all of your userland requirements, update your SSH keys (if applicable), and try again.\n"
      echo "Good Luck!"
    fi
    ;;
  *)
    usage
    ;;
esac
date -u +%Y-%m-%d_%H.%M.%S
