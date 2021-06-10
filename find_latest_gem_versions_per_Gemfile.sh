#!/bin/bash --login
# Uncomment when watir 7 is released.
# cat Gemfile | awk '{print $2}' | grep -E "^'.+$" | grep -v rubygems.org | while read gem; do 
cat Gemfile | awk '{print $2}' | grep -E "^'.+$" | grep -v rubygems.org | grep -v watir | while read gem; do 
  this_gem=`echo $gem | sed "s/'//g" | sed 's/\,//g'`
  latest_version=`gem search -r $this_gem | grep -E "^${this_gem}\s.+$" | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/,//g'`
  echo "${this_gem} => $latest_version"
  sed -i '' "s/^gem '${this_gem}'.*$/gem '${this_gem}', '${latest_version}'/g" Gemfile
done
