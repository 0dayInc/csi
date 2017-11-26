#!/bin/bash --login
# Quick Prototyping of Exploits
# $ ipython
# in [1]: from pwn import *
# More information available here: https://docs.pwntools.com/en/stable/
sudo -H /bin/bash --login -c "apt-get update && apt-get install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential && pip install --upgrade pip && pip install --upgrade pwntools"
