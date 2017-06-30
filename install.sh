#!/bin/bash
csi_deploy_type=$1
os=$(uname -s)

# TODO: Check that all configs exist
# MAKE .EXAMPLE and actual file the same
# if they're the same size prompt user to 
# configure
# TODO: install ansible in this script if not installed
# to take advantage of encrypted configs early on

function usage() {
  echo $"Usage: $0 <aws|ruby-gem|virtualbox|virtualbox-gui|vmware-fusion|vmware-fusion-gui|vmware-workstation|vmware-workstation-gui>"
  exit 1
}

if [[ $# != 1 ]]; then
  usage
fi

if [[ ! -e "./etc/metasploit/msfrpcd.yaml" ]]; then
  echo "ERROR: Missing msfrpcd.yaml Config"
  echo "Use ./etc/metasploit/msfrpcd.yaml.EXAMPLE as a Template to Create ./etc/metasploit/msfrpcd.yaml"
  exit 1
fi

case $csi_deploy_type in
  "aws") 
    if [[ -e "./etc/aws/vagrant.yaml" ]]; then
      vagrant plugin install vagrant-aws
      vagrant plugin install vagrant-aws-dns
      vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box --force
      vagrant up --provider=aws
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/aws/vagrant.yaml.EXAMPLE as a Template to Create ./etc/aws/vagrant.yaml"
    fi
    ;;
  "ruby-gem")
    ./packer/provisioners/rvm.sh
    ./packer/provisioners/ruby.sh
    ./packer/provisioners/csi.sh
    ;;
  "virtualbox"|"virtualbox-gui")
    if [[ -e "./etc/virtualbox/vagrant.yaml" ]]; then
      if [[ $csi_deploy_type == "virtualbox-gui" ]]; then
        export VAGRANT_GUI="gui"
      else
        export VAGRANT_GUI="headless"
      fi
      vagrant up --provider=virtualbox
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/virtualbox/vagrant.yaml.EXAMPLE as a Template to Create ./etc/virtualbox/vagrant.yaml"
    fi
    ;;
  "vmware-fusion"|"vmware-fusion-gui")
    if [[ -e "./etc/vmware/vagrant.yaml" ]]; then
      if [[ $csi_deploy_type == "vmware-fusion-gui" ]]; then
        export VAGRANT_GUI="gui"
      else
        export VAGRANT_GUI="headless"
      fi
      vagrant plugin install vagrant-vmware-fusion
      license_file=$(ruby -e "require 'yaml'; print YAML.load_file('./etc/vmware/vagrant.yaml')['vagrant_vmware_license']")
      vagrant plugin license vagrant-vmware-fusion $license_file
      vagrant up --provider=vmware_fusion
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/vmware/vagrant.yaml.EXAMPLE as a Template to Create ./etc/vmware/vagrant.yaml"
    fi
    ;;
  "vmware-workstation"|"vmware-workstation-gui")
    if [[ -e "./etc/vmware/vagrant.yaml" ]]; then
      if [[ $csi_deploy_type == "vmware-workstation-gui" ]]; then
        export VAGRANT_GUI="gui"
      else
        export VAGRANT_GUI="headless"
      fi
      vagrant plugin install vagrant-vmware-workstation
      license_file=$(ruby -e "require 'yaml'; print YAML.load_file('./etc/vmware/vagrant.yaml')['vagrant_vmware_license']")
      vagrant plugin license vagrant-vmware-workstation $license_file
      vagrant up --provider=vmware_workstation
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/vmware/vagrant.yaml.EXAMPLE as a Template to Create ./etc/vmware/vagrant.yaml"
    fi
    ;;
  *)
    usage
    ;;
esac
