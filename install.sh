#!/bin/bash
csi_deploy_type=$1

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
    export rvmsudo_secure_path=0
    rubyv=$(cat .ruby-version)
    gemset=$(cat .ruby-gemset)
    source /etc/profile.d/rvm.sh
    rvm install ${ruby_version}
    rvm use ${ruby_version}
    rvm gemset create ${gemset}
    rvm use --default ${ruby_version}@${gemset}
    gem install bundler
    # TODO: identify os installed on & determine if proper postgres packages are installed for 'pg' gem
    if [[ $(uname -s) == "Darwin" ]]; then
      bundle config build.pg --with-pg-config=/opt/local/lib/postgresql96/bin/pg_config
    fi
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
    #echo $"Usage: $0 <android (c. soon)|aws|docker(c. soon)|elasticbeanstalk(c. soon)|iphone (c. soon)|ruby-gem|virtualbox|virtualbox-gui>"
    echo $"Usage: $0 <aws|ruby-gem|virtualbox|virtualbox-gui>"
    exit 1
esac
