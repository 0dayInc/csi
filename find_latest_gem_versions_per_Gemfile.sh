#!/bin/bash --login
cat Gemfile | awk '{print $2}' | grep -E "^'.+$" | grep -v rubygems.org | while read gem; do 
  this_gem=`echo $gem | sed "s/'//g" | sed 's/\,//g'`
  gem search -r $this_gem | grep -E "^${this_gem}\s.+$"
done
