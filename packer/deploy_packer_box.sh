#!/bin/bash
provider_type=$1
box_version=$2
debug=false
export PACKER_LOG=1
set -e

function usage() {
  echo "USAGE: ${0} <docker||docker_csi||virtualbox||vmware> <box version to build e.g. 2018.3a.1> <debug>"
  exit 1
}

function pack() {
  provider_type=$1
  packer_provider_template=$2
  debug=$3
  packer_secrets='packer_secrets.json'

  if $debug; then
    packer build \
      -debug \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  else
    packer build \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  fi 
}

if [[ $# < 2 ]]; then
  usage
fi

if [[ $3 != '' ]]; then
  debug=true
fi

case $provider_type in
  "docker")
    rm kali_rolling_docker.box || true
    pack docker kali_rolling_docker.json $debug
    vagrant box remove csi/kali_rolling --provider=docker|| true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_docker.box
    ;;
  "docker_csi")
    rm kali_rolling_docker_csi.box || true
    pack docker kali_rolling_docker_csi.json $debug
    vagrant box remove csi/prototyper --provider=docker || true
    vagrant box add --box-version $box_version csi/prototyper kali_rolling_docker_csi.box
    ;;
  "virtualbox")
    rm kali_rolling_virtualbox.box || true
    pack virtualbox-iso kali_rolling_virtualbox.json $debug
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    echo $debug
    rm kali_rolling_vmware.box || true
    pack vmware-iso kali_rolling_vmware.json $debug
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
