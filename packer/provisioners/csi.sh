#!/bin/bash --login

sudo apt-get install -y fontconfig postgresql-server-dev-all libpcap-dev libsndfile1 libsndfile1-dev libmagickwand-dev imagemagick tesseract-ocr-all

sudo bash --login -c 'cd /csi && cp etc/metasploit/msfrpcd.yaml.EXAMPLE etc/metasploit/msfrpcd.yaml && ./install.sh ruby-gem'
