#!/bin/bash --login
./deploy_packer_box.sh | grep docker | awk '{print $1}' | while read c; do 
  ./deploy_packer_box.sh $c latest
done
