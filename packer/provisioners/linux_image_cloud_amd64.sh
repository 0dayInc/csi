#!/bin/bash --login
sudo apt install -y linux-image-cloud-amd64
sudo update-initramfs -u
sudo apt install -y linux-headers-cloud-amd64
