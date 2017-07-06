# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

API_VERSION = '2'
vagrant_gui = ENV['VAGRANT_GUI'] if ENV['VAGRANT_GUI']
vagrant_provider = ENV['VAGRANT_PROVIDER'] if ENV['VAGRANT_PROVIDER']

Vagrant.configure(API_VERSION) do |config|
  hostname = ''
  config.vm.box = 'csi/kali_rolling'

  config.vm.provider(:virtualbox) do |vb, override|
    config_path = './etc/virtualbox/vagrant.yaml'
    if File.exist?(config_path) && vagrant_provider == 'virtualbox'
      yaml_config = YAML.load_file(config_path)

      vb.gui = if vagrant_gui == 'true'
                 true
               else
                 false
               end

      vb.memory = yaml_config['memory']
      hostname = yaml_config['hostname']
      diskMB = yaml_config['diskMB']
      override.vm.hostname = hostname
      override.vm.guest = :debian

      # TODO: resize disk based on params listed in etc/virtualbox/vagrant.yaml
      # disk_uuid = ''
      # while disk_uuid == ''
      #   disk_uuid = `VBoxManage list hdds | grep -B 8 '10240 MBytes' | head -n 1 | awk '{print $2}'`.to_s.scrub.strip.chomp
      #   sleep 3
      # end

      # vb.customize ['modifyhd', "#{disk_uuid}", '--resize', "#{diskMB}"]
    end
  end

  %i[vmware_fusion vmware_workstation].each do |vmware_provider|
    config_path = './etc/virtualbox/vmware.yaml'
    if File.exist?(config_path) && vagrant_provider == 'vmware'
      config.vm.provider(vmware_provider) do |vm, override|
        yaml_config = YAML.load_file('./etc/vmware/vagrant.yaml')

        if vagrant_gui == 'true'
          vm.gui = true
        else
          vm.gui = false
        end
        vagrant_vmware_license = yaml_config['vagrant_vmware_license']
        vm.memory = yaml_config['memory']
        hostname = yaml_config['hostname']
        diskMB = yaml_config['diskMB']
        override.vm.hostname = hostname
        override.vm.guest = :debian
      end
    end
  end

  config.vm.provider(:aws) do |aws, override|
    config_path = './etc/aws/vagrant.yaml'
    if File.exist?(config_path) && vagrant_provider == 'aws'
      override.vm.box = 'dummy'
      yaml_config = YAML.load_file(config_path)

      hostname = yaml_config['hostname']

      aws_init_script = "#!/bin/bash\necho \"Updating FQDN: #{hostname}\"\ncat /etc/hosts | grep \"#{hostname}\" || sudo sed 's/127.0.0.1/127.0.0.1 #{hostname}/g' -i /etc/hosts\nhostname | grep \"#{hostname}\" || sudo hostname \"#{hostname}\"\nsudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers\necho 'Defaults:ubuntu !requiretty' >> /etc/sudoers"

      aws.access_key_id = yaml_config['access_key_id']
      aws.secret_access_key = yaml_config['secret_access_key']
      aws.keypair_name = yaml_config['keypair_name']

      aws.ami = yaml_config['ami']
      aws.block_device_mapping = yaml_config['block_device_mapping']
      aws.region = yaml_config['region']
      aws.monitoring = yaml_config['monitoring']
      aws.elastic_ip = yaml_config['elastic_ip']
      aws.associate_public_ip = yaml_config['associate_public_ip']
      aws.private_ip_address = yaml_config['private_ip_address']
      aws.subnet_id = yaml_config['subnet_id']
      aws.instance_type = yaml_config['instance_type']
      aws.iam_instance_profile_name = yaml_config['iam_instance_profile_name']
      aws.security_groups = yaml_config['security_groups']
      aws.tags = yaml_config['tags']
      # Hack for dealing w/ images that require a pty when using sudo and changing hostname
      aws.user_data = aws_init_script

      override.ssh.username = yaml_config['ssh_username']
      override.ssh.private_key_path = yaml_config['ssh_private_key_path']
      override.dns.record_sets = yaml_config['record_sets']
    end
  end

  # Update Key Items After CSI Box has Booted
  config.vm.provision :shell, path: './vagrant/provisioners/init_env.sh', args: hostname, privileged: false
  config.vm.provision :shell, path: './vagrant/provisioners/update_os.sh', privileged: false
  config.vm.provision :shell, path: './vagrant/provisioners/rvm.sh', privileged: false
  config.vm.provision :shell, path: './vagrant/provisioners/gem.sh', privileged: false
  # config.vm.provision :shell, path: './vagrant/provisioners/metasploit.rb', privileged: false
  # config.vm.provision :shell, path: './vagrant/provisioners/wpscan.rb', privileged: false
  # config.vm.provision :shell, path: './vagrant/provisioners/ssllabs-scan.sh', privileged: false
  config.vm.provision :shell, path: './vagrant/provisioners/update_openvas_feeds.sh', privileged: false
  config.vm.provision :shell, path: './vagrant/provisioners/csi.sh', privileged: false
end
