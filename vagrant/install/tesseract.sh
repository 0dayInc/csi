#!/bin/bash --login
printf "Installing Tesseract OCR **************************************************************"
sudo /bin/bash --login -c "apt-get install -y tesseract-ocr-all && cd /usr/share/tesseract-ocr && wget https://tesseract-ocr.googlecode.com/files/eng.traineddata.gz && gunzip eng.traineddata.gz && cd -"
