#!/bin/bash
provider_type=$1
box_version=$2
debug=false
export PACKER_LOG=1
set -e

function usage() {
  echo "USAGE: ${0} <aws_ami||docker||docker_csi||kvm||virtualbox||vmware> <box version to build e.g. 2019.2.1> <debug>"
  exit 1
}

function pack() {
  provider_type=$1
  packer_provider_template=$2
  debug=$3
  packer_secrets='packer_secrets.json'

  if $debug; then
    packer build \
      -debug \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  else
    packer build \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  fi 
}

if [[ $# < 2 ]]; then
  usage
fi

if [[ $3 != '' ]]; then
  debug=true
fi

case $provider_type in
  "aws_ami")
    # Enable SSH
    # Inside the web UI, navigate to “Manage”, then the “Services” tab. Find the entry called: “TSM-SSH”, and enable it.

    # You may wish to enable it to start up with the host by default. You can do this inside the “Actions” dropdown (it’s nested inside “Policy”).

    # Enable “Guest IP Hack”
    # Run the following command on the ESXi host:
    # 
    # esxcli system settings advanced set -o /Net/GuestIPHack -i 1
    # This allows Packer to infer the guest IP from ESXi, without the VM needing to report it itself.
    # 
    # Open VNC Ports on the Firewall
    # Packer connects to the VM using VNC, so we’ll open a range of ports to allow it to connect to it.

    # First, ensure we can edit the firewall configuration:

    # chmod 644 /etc/vmware/firewall/service.xml
    # chmod +t /etc/vmware/firewall/service.xml
    # Then append the range we want to open to the end of the file:

    # <service id="1000">
    #   <id>packer-vnc</id>
    #   <rule id="0000">
    #     <direction>inbound</direction>
    #     <protocol>tcp</protocol>
    #     <porttype>dst</porttype>
    #     <port>
    #       <begin>5900</begin>
    #       <end>6000</end>
    #     </port>
    #   </rule>
    #   <enabled>true</enabled>
    #   <required>true</required>
    # </service>
    # Finally, restore the permissions and reload the firewall:
    # 
    # chmod 444 /etc/vmware/firewall/service.xml
    # esxcli network firewall refresh
    echo $debug
    rm kali_rolling_vmware.box || true
    pack vmware-iso kali_rolling_aws_ami.json $debug
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    ;;
  "docker")
    rm kali_rolling_docker.box || true
    pack docker kali_rolling_docker.json $debug
    vagrant box remove csi/kali_rolling --provider=docker|| true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_docker.box
    ;;
  "docker_csi")
    rm kali_rolling_docker_csi.box || true
    pack docker kali_rolling_docker_csi.json $debug
    vagrant box remove csi/prototyper --provider=docker || true
    vagrant box add --box-version $box_version csi/prototyper kali_rolling_docker_csi.box
    ;;
  "kvm")
    rm kali_rolling_qemu_kvm_xen.box || true
    pack qemu kali_rolling_qemu_kvm_xen.json $debug
    vagrant box remove csi/kali_rolling --provider=qemu || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_qemu_kvm_xen.box
    ;;
  "virtualbox")
    rm kali_rolling_virtualbox.box || true
    pack virtualbox-iso kali_rolling_virtualbox.json $debug
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    echo $debug
    rm kali_rolling_vmware.box || true
    pack vmware-iso kali_rolling_vmware.json $debug
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
