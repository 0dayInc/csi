#!/bin/bash --login
./deploy_packer_box.sh | grep docker | awk '{print $1}' | while read c; do 
  ./deploy_packer_box.sh $c latest
  docker images -a | grep -v csi_prototyper | awk '{print $3}' | while read i; do docker rmi --force $i; done
  docker system prune -f
  sleep 9
done
