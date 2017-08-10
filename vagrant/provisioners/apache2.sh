#!/bin/bash
domain_name=$(hostname -d)
sudo /bin/bash --login -c "echo -e '127.0.0.1\tjenkins.${domain_name}' >> /etc/hosts"
sudo /bin/bash --login -c "echo -e '127.0.0.1\topenvas.${domain_name}' >> /etc/hosts"
sudo /bin/bash --login -c "sed -i \"s/DOMAIN/${domain_name}/g\" /etc/apache2/sites-available/*.conf"
sudo ln -s /etc/apache2/sites-available/jenkins_80.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/jenkins_443.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/openvas_80.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/openvas_443.conf /etc/apache2/sites-enabled/

tls_deployment_type=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['tls_deployment_type']"`

case $tls_deployment_type in
  'letsencrypt')
    # Public Facing
    /csi/vagrant/provisioners/letsencrypt.rb
    ;;
  'self_signed')
    # Internally Hosted
    sudo mkdir /etc/apache2/ssl

    country_name=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['country_name']"`
    state_or_prov=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['state_or_prov']"`
    city_name=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['city_name']"`
    org_company_name=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['org_company_name']"`
    org_unit_name=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['org_unit_name']"`
    common_name_fqdn=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['common_name_fqdn']"`
    email_addr=`ruby -e "require 'yaml'; print YAML.load_file('/csi/etc/apache2/vagrant.yaml')['email_addr']"`

    sudo openssl req \
      -x509 -nodes -days 999 -newkey rsa:4096 \
      -keyout /etc/apache2/ssl/jenkins.key \
      -out /etc/apache2/ssl/jenkins.crt \
      -subj "/C=${country_name}/ST=${state_or_prov}/L=${city_name}/O=${org_company_name}/OU=${org_unit_name}/CN=jenkins.${common_name_fqdn}/emailAddress=${email_addr}"

    sudo openssl req \
      -x509 -nodes -days 999 -newkey rsa:4096 \
      -keyout /etc/apache2/ssl/openvas.key \
      -out /etc/apache2/ssl/openvas.crt \
      -subj "/C=${country_name}/ST=${state_or_prov}/L=${city_name}/O=${org_company_name}/OU=${org_unit_name}/CN=openvas.${common_name_fqdn}/emailAddress=${email_addr}"
    
    # Replace LetsEncrypt TLS Entries w/ Self-Signed for OpenVAS
    sudo sed -i '12s/.*/SSLCertificateFile \/etc\/apache2\/ssl\/jenkins\.crt/' \
      /etc/apache2/sites-available/jenkins_443.conf
    sudo sed -i '13s/.*/SSLCertificateKeyFile \/etc\/apache2\/ssl\/jenkins\.key/' \
      /etc/apache2/sites-available/jenkins_443.conf
    sudo sed -i '14s/.*//' /etc/apache2/sites-available/jenkins_443.conf

    # Replace LetsEncrypt TLS Entries w/ Self-Signed for OpenVAS
    sudo sed -i '12s/.*/SSLCertificateFile \/etc\/apache2\/ssl\/openvas\.crt/' \
      /etc/apache2/sites-available/openvas_443.conf
    sudo sed -i '13s/.*/SSLCertificateKeyFile \/etc\/apache2\/ssl\/openvas\.key/' \
      /etc/apache2/sites-available/openvas_443.conf
    sudo sed -i '14s/.*//' /etc/apache2/sites-available/openvas_443.conf
    ;;
  *)
    echo "No tls_deployment_type Specified in /csi/etc/apache2/vagrant.yaml for Apache2 Virtual Hosting"
    exit 1
esac

sudo systemctl enable apache2
sudo systemctl start apache2
