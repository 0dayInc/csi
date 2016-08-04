#!/bin/bash
csi_deploy_type=$1
os=$(uname -s)

# TODO: Check that all configs exist
# MAKE .EXAMPLE and actual file the same
# if they're the same size prompt user to 
# configure
# TODO: install ansible in this script if not installed
# to take advantage of encrypted configs early on
case $csi_deploy_type in
  "aws") 
    if [[ -e "./etc/aws/vagrant.yaml" ]]; then
      vagrant plugin install vagrant-aws
      vagrant plugin install vagrant-aws-dns
      vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box --force
      vagrant up --provider=aws
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/aws/vagrant.yaml.EXAMPLE as a Template to Create ./etc/aws/vagrant.yaml"
    fi
    ;;
  "ruby-gem")
    case $os in
      "Darwin")
        ruby_version=$(cat .ruby-version)
        gemset=$(cat .ruby-gemset)
        source /etc/profile.d/rvm.sh
        rvm install ${ruby_version}
        rvm use ${ruby_version}
        rvm gemset create ${gemset}
        rvm use --default ${ruby_version}@${gemset}
        gem install bundler
        bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
    
        echo "Installing wget to retrieve tesseract trained data..."
        port install wget

        echo "Installing Postgres Libraries for pg gem..."
        port install postgresql96-server

        echo "Installing libpcap Libraries..."
        port install libpcap

        echo "Installing ImageMagick..."
        port install imagemagick

        echo "Installing Tesseract OCR..."
        port install tesseract
        cd /opt/local/share/tessdata && wget https://tesseract-ocr.googlecode.com/files/eng.traineddata.gz && gunzip eng.traineddata.gz
        ;;
      "Linux")
        apt-get --version
        if [[ $? == 0 ]]; then
          ruby_version=$(cat .ruby-version)
          gemset=$(cat .ruby-gemset)
          source /etc/profile.d/rvm.sh
          rvm install ${ruby_version}
          rvm use ${ruby_version}
          rvm gemset create ${gemset}
          rvm use --default ${ruby_version}@${gemset}
          gem install bundler
          
          echo "Installing wget to retrieve tesseract trained data..."
          apt-get install wget

          echo "Installing Postgres Libraries for pg gem..."
          apt-get install postgresql-server-dev-all

          echo "Installing libpcap Libraries..."
          apt-get install libpcap-dev

          echo "Installing ImageMagick..."
          apt-get install libmagickwand-dev imagemagick

          echo "Installing Tesseract OCR..."
          apt-get install tesseract-ocr-all
          cd /usr/share/tesseract-ocr && wget https://tesseract-ocr.googlecode.com/files/eng.traineddata.gz && gunzip eng.traineddata.gz
        else
          echo "A Linux Distro was Detected, however, CSI currently only supports OSX & Ubuntu for now...yucky-yuck, I know."
        fi
        ;;
      *)
        echo "${os} not currently supported."
        exit 1
    esac

    bundle install
    ./build_csi_gem.sh
    ;;
  "virtualbox"|"virtualbox-gui")
    if [[ -e "./etc/virtualbox/vagrant.yaml" ]]; then
      if [[ $csi_deploy_type == "virtualbox-gui" ]]; then
        export VAGRANT_VBOX_GUI="gui"
      else
        export VAGRANT_VBOX_GUI="headless"
      fi
      vagrant up --provider=virtualbox
    else
      echo "ERROR: Missing vagrant.yaml Config"
      echo "Use ./etc/virtualbox/vagrant.yaml.EXAMPLE as a Template to Create ./etc/virtualbox/vagrant.yaml"
    fi
    ;;
  *)
    echo $"Usage: $0 <aws|ruby-gem|virtualbox|virtualbox-gui>"
    exit 1
esac
