#!/bin/bash --login
printf "Installing Tesseract OCR **************************************************************"
sudo /bin/bash --login -c "apt-get install -y tesseract-ocr-all && cd /usr/share/tesseract-ocr && wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata && cd -"
