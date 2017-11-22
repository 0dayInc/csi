#!/bin/bash
provider_type=$1
box_version=$2
debug=false
set -e

function usage() {
  echo "USAGE: ${0} <docker||docker_csi||virtualbox||vmware> <box version to build e.g. 2017.3.001> <debug>"
  exit 1
}

if [[ $# < 2 ]]; then
  usage
fi

if [[ $3 != '' ]]; then
  debug=true
  export PACKER_LOG=1
fi

case $provider_type in
  "docker")
    rm kali_rolling_docker.box || true
    if $debug; then
      packer build \
        -debug \
        -only docker \
        kali_rolling_docker.json
    else
      packer build \
        -only docker \
        kali_rolling_docker.json
    fi
    vagrant box remove csi/kali_rolling --provider=docker|| true
    vagrant box add csi/kali_rolling kali_rolling_docker.box
    ;;
  "docker_csi")
    rm kali_rolling_docker_csi.box || true
    if $debug; then
      packer build \
        -debug \
        -only docker \
        kali_rolling_docker_csi.json
    else
      packer build \
        -only docker \
        kali_rolling_docker_csi.json
    fi
    vagrant box remove csi/prototyper --provider=docker || true
    vagrant box add csi/prototyper kali_rolling_docker_csi.box
    ;;
  "virtualbox")
    rm kali_rolling_virtualbox.box || true
    if $debug; then
      packer build \
        -debug \
        -only virtualbox-iso \
        -var "box_version=${box_version}" \
        -var-file=packer_secrets.json \
        kali_rolling_virtualbox.json
    else
      packer build \
        -only virtualbox-iso \
        -var "box_version=${box_version}" \
        -var-file=packer_secrets.json \
        kali_rolling_virtualbox.json
    fi
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    echo $debug
    rm kali_rolling_vmware.box || true
    if $debug; then
      packer build \
        -debug \
        -only vmware-iso \
        -var "box_version=${box_version}" \
        -var-file=packer_secrets.json \
        kali_rolling_vmware.json
    else
      packer build \
        -only vmware-iso \
        -var "box_version=${box_version}" \
        -var-file=packer_secrets.json \
        kali_rolling_vmware.json
    fi
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
