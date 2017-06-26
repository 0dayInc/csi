#!/bin/bash --login

sudo apt-get install -y fontconfig postgresql-server-dev-all libpcap-dev libsndfile1 libsndfile1-dev libmagickwand-dev imagemagick tesseract-ocr-all

sudo bash --login -c "cd /csi && ./install.sh ruby-gem"
