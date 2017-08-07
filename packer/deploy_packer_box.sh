#!/bin/bash
provider_type=$1
set -e

function usage() {
  echo "USAGE: ${0} <docker||docker_csi||virtualbox||vmware>"
  exit 1
}

if [[ $# < 1 ]]; then
  usage
fi

case $provider_type in
  "docker")
    #export PACKER_LOG=1
    rm kali_rolling_docker.box || true
    packer build -only docker kali_rolling_docker.json
    vagrant box remove csi/kali_rolling --provider=docker|| true
    vagrant box add csi/kali_rolling kali_rolling_docker.box
    ;;
  "docker_csi")
    #export PACKER_LOG=1
    rm kali_rolling_docker_csi.box || true
    packer build -only docker kali_rolling_docker_csi.json
    vagrant box remove csi/prototyper --provider=docker || true
    vagrant box add csi/prototyper kali_rolling_docker_csi.box
    ;;
  "virtualbox")
    #export PACKER_LOG=1
    rm kali_rolling_virtualbox.box || true
    packer build -only virtualbox-iso -var-file=packer_secrets.json kali_rolling_virtualbox.json
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    #export PACKER_LOG=1
    rm kali_rolling_vmware.box || true
    packer build -only vmware-iso -var-file=packer_secrets.json kali_rolling_vmware.json
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
