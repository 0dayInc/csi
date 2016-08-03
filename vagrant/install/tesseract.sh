#!/bin/bash --login
printf "Installing Tesseract OCR **************************************************************"
sudo apt-get install -y tesseract-ocr-all
sudo /etc/init.d/lxdm restart
