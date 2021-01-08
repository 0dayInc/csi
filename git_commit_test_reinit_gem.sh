#!/bin/bash
if [[ $1 != "" && $2 != "" && $3 != "" ]]; then
  # Default Strategy is to merge codebase
  git config pull.rebase false
  git pull
  git add . --all
  echo 'Updating Gems to Latest Versions in Gemfile...'
  ./find_latest_gem_versions_per_Gemfile.sh
  csi_autoinc_version
  git commit -a -S --author="${1} <${2}>" -m "${3}"
  ./update_csi.sh
  tag_this_version_bool=`ruby -r 'csi' -e 'if CSI::VERSION.split('.')[-1].to_i == 0; then print true; else print false; end'`
  if [[ $tag_this_version_bool == 'true' ]]; then
    this_version=`ruby -r 'csi' -e 'print CSI::VERSION'`
    echo "Tagging: ${this_version}"
    git tag $this_version
  fi
else
  echo "USAGE: ${0} '<full name>' <email address> '<git commit comments>'"
fi
