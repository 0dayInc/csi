#!/bin/bash
packer_file=$1
provider_type=$2
set -e

function usage() {
  echo "USAGE: ${0} <packer_provider_template.json> <provider type>"
  exit 1
}

if [[ $# < 1 ]]; then
  usage
fi

case $provider_type in
  "virtualbox")
    #export PACKER_LOG=1
    rm kali_rolling_virtualbox.box || true
    #packer build -debug -only virtualbox-iso $packer_file
    packer build -only virtualbox-iso $packer_file
    vagrant box remove kali_rolling_virtualbox || true
    vagrant box add kali_rolling_virtualbox kali_rolling_virtualbox.box
    ;;
  "vmware")
    #export PACKER_LOG=1
    rm kali_rolling_vmware.box || true
    #packer build -debug -only virtualbox-iso $packer_file
    packer build -only vmware-iso $packer_file
    vagrant box remove kali_rolling_vmware || true
    vagrant box add kali_rolling_vmware kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
