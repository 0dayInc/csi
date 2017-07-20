#!/bin/bash --login
os=$(uname -s)

case $os in
  "Darwin")
    echo 'Installing wget to retrieve tesseract trained data...'
    sudo port -N install wget

    echo "Installing fontconfig..."
    sudo port -N install fontconfig

    echo 'Installing Postgres Libraries for pg gem...'
    sudo port -N install postgresql96-server

    echo 'Installing libpcap Libraries...'
    sudo port -N install libpcap

    echo "Installing libsndfile1 & libsndfile1-dev Libraries..."
    sudo port -N install libsndfile

    echo 'Installing ImageMagick...'
    sudo port -N install imagemagick

    echo 'Installing Tesseract OCR...'
    sudo port -N install tesseract
    sudo /bin/bash --login -c 'cd /opt/local/share/tessdata && wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata'
    ;;
  "Linux")
    apt-get --version > /dev/null 2>&1
    if [[ $? == 0 ]]; then
      echo "Installing wget to retrieve tesseract trained data..."
      sudo apt-get install -y wget

      echo "Installing fontconfig..."
      sudo apt-get install -y fontconfig

      echo "Installing Postgres Libraries for pg gem..."
      sudo apt-get install -y postgresql-server-dev-all

      echo "Installing libpcap Libraries..."
      sudo apt-get install -y libpcap-dev

      echo "Installing libsndfile1 & libsndfile1-dev Libraries..."
      sudo apt-get install -y libsndfile1 libsndfile1-dev

      echo "Installing imagemagick & libmagickwand-dev Libraries..."
      sudo apt-get install -y imagemagick libmagickwand-dev

      echo "Installing tesseract-ocr-all & trainers..."
      sudo /bin/bash --login -c 'apt-get install -y tesseract-ocr-all && cd /usr/share/tesseract-ocr && wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata'
    else
      echo "A Linux Distro was Detected, however, ${0} currently only supports Kali Rolling, Ubuntu, & OSX for now...feel free to install manually."
    fi
    ;;
  *)
    echo "${os} not currently supported."
    exit 1
esac

sudo bash --login -c 'cd /csi && cp etc/metasploit/vagrant.yaml.EXAMPLE etc/metasploit/vagrant.yaml && sudo ./reinstall_csi_gemset.sh && ./build_csi_gem.sh && rubocop'
