#!/bin/bash
if [[ $1 != "" && $2 != "" && $3 != "" ]]; then
  git pull
  csi_autoinc_version
  git add . --all
  git commit -a -S --author="${1} <${2}>" -m "${3}"
  ./update_csi.sh
else
  echo "USAGE: ${0} '<full name>' <email address> '<git commit comments>'"
fi
