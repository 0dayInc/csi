#!/bin/bash --login
# PEDA - Python Exploit Development Assistance for GDB to be used w/ AFL
sudo apt install -y libini-config-dev
sudo /bin/bash --login -c 'cd /opt && git clone https://github.com/zardus/preeny preeny-dev && cd /opt/preeny-dev && make'
