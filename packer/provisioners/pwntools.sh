#!/bin/bash --login
# Quick Prototyping of Exploits
# $ ipython
# in [1]: from pwn import *
# More information available here: https://docs.pwntools.com/en/stable/
#sudo /bin/bash --login -c "apt update && apt install -y python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential && pip install --upgrade pip && pip install --upgrade pwntools"
sudo /bin/bash --login -c "apt update && apt install -y python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential && pip install pwntools"
