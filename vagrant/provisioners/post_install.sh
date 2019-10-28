#!/bin/bash --login
# Change csiadmin password at first login
sudo passwd --expire admin
sudo userdel -r csiadmin

# Regenerate SSH Keys
# RSA
yes y | sudo ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 8192
# DSA
yes y | sudo ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa -b 1024
# ECDSA
yes y | sudo ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
