#!/bin/bash --login
cd $CSI_ROOT/packer && ./deploy_packer_box.sh | grep docker | awk '{print $1}' | while read c; do 
  ./deploy_packer_box.sh $c latest
  docker images -a | grep -v -e REPOSITORY -e csi_prototyper -e kali-linux-docker | awk '{print $3}' | while read i; do docker rmi --force $i; done
  docker system prune -f
  sleep 9
done
