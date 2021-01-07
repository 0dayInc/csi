#!/bin/bash
if [[ $1 != "" && $2 != "" && $3 != "" ]]; then
  # Default Strategy is to merge codebase
  git config pull.rebase false
  git pull
  csi_autoinc_version
  git add . --all
  echo 'Updating Gems to Latest Versions in Gemfile...'
  ./find_latest_gem_versions_per_Gemfile.sh
  git commit -a -S --author="${1} <${2}>" -m "${3}"
  ./update_csi.sh
else
  echo "USAGE: ${0} '<full name>' <email address> '<git commit comments>'"
fi
