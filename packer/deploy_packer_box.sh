#!/bin/bash
packer_file=$1
set -e

function usage() {
  echo "USAGE: ${0} <packer_provider_template.json>"
  exit 1
}

if [[ $# < 1 ]]; then
  usage
fi

#export PACKER_LOG=1
rm kali_rolling_virtualbox.box || true
#packer build -debug -only virtualbox-iso $packer_file
packer build -only virtualbox-iso $packer_file
vagrant box remove kali_rolling_virtualbox || true
vagrant box add kali_rolling_virtualbox kali_rolling_virtualbox.box
