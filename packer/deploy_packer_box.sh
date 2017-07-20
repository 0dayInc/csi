#!/bin/bash
packer_file=$1
provider_type=$2
set -e

function usage() {
  echo "USAGE: ${0} <packer_provider_template.json> <docker||docker_csi||virtualbox||vmware>"
  exit 1
}

if [[ $# < 2 ]]; then
  usage
fi

case $provider_type in
  "docker")
    #export PACKER_LOG=1
    rm kali_rolling_docker.box || true
    #packer build -debug -only docker $packer_file
    packer build -only docker $packer_file
    vagrant box remove csi/kali_rolling --provider=docker|| true
    vagrant box add csi/kali_rolling kali_rolling_docker.box
    ;;
  "docker_csi")
    #export PACKER_LOG=1
    rm kali_rolling_docker_csi.box || true
    #packer build -debug -only docker $packer_file
    packer build -only docker $packer_file
    vagrant box remove csi/prototyper --provider=docker || true
    vagrant box add csi/prototyper kali_rolling_docker_csi.box
    ;;
  "virtualbox")
    #export PACKER_LOG=1
    rm kali_rolling_virtualbox.box || true
    #packer build -debug -only virtualbox-iso $packer_file
    packer build -only virtualbox-iso $packer_file
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    #export PACKER_LOG=1
    rm kali_rolling_vmware.box || true
    #packer build -debug -only virtualbox-iso $packer_file
    packer build -only vmware-iso $packer_file
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
