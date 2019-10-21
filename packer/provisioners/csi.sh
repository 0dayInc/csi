#!/bin/bash --login
if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`
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
    apt --version > /dev/null 2>&1
    if [[ $? == 0 ]]; then
      echo "Installing wget to retrieve tesseract trained data..."
      sudo apt install -y wget

      echo "Installing fontconfig..."
      sudo apt install -y fontconfig

      echo "Installing Postgres Libraries for pg gem..."
      sudo apt install -y postgresql-server-dev-all

      echo "Installing libpcap Libraries..."
      sudo apt install -y libpcap-dev

      echo "Installing libsndfile1 & libsndfile1-dev Libraries..."
      sudo apt install -y libsndfile1 libsndfile1-dev

      echo "Installing imagemagick & libmagickwand-dev Libraries..."
      sudo apt install -y imagemagick libmagickwand-dev

      echo "Installing tesseract-ocr-all & trainers..."
      sudo /bin/bash --login -c 'apt install -y tesseract-ocr-all && cd /usr/share/tesseract-ocr && wget https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata'
    else
      echo "A Linux Distro was Detected, however, ${0} currently only supports Kali Rolling, Ubuntu, & OSX for now...feel free to install manually."
    fi
    ;;
  *)
    echo "${os} not currently supported."
    exit 1
esac

sudo /bin/bash --login -c "cd ${csi_root} && cp etc/userland/${csi_provider}/metasploit/vagrant.yaml.EXAMPLE etc/userland/${csi_provider}/metasploit/vagrant.yaml && sudo ./reinstall_csi_gemset.sh && ./build_csi_gem.sh && rubocop"
