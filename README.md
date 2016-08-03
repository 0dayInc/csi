### **Intro** ###
It's easy to agree that while corporate automation is a collection of proprietary source code, there's no reason the core in which automation is produced should be anything but open...broad collaboration is key to any automation framework's success, particularly in the cyber security arena.  Introducing CSI (Continuous Security Integration) - a security automation framework that aims to stand on the shoulders of security giants.

### **Call to Arms** ###
If you're willing to provide access to commercial security tools (e.g. Rapid7's Nexpose, Tenable Nessus, QualysGuard, HP WebInspect, IBM Appscan, etc) please PM me as this will continue to promote CSIs interoperability w/ industry-recognized security tools moving forward.

### **Installation** ###
**Supported Operating Systems:** Linux & OSX

Think of the cloned CSI repo as the root folder for your security automation...you can install CSI locally as a gem (recommended) and also deploy a full Linux image w/ CSI installed on the following:

  - AWS
  - VirtualBox

which is also recommended :)


### **CSI Installation Dependencies** ###
  - Macports (if OS == OSX)
  - rvm
  - rsync
  - Oracle VirtualBox
  - Oracle VM VirtualBox Extension Pack
  - Vagrant
  - Ansible
  - AWS Account (only if installing via: sudo ./install.sh aws)
  - postgresql dev libraries
  - libpcap dev libraries

### **Clone the repo** ###

 `$ sudo git clone https://github.com/ninp0/csi.git /opt/csi`

### **Install CSI in AWS (Be Sure to Take a Look at the AWS Acceptable Use Policy: https://aws.amazon.com/aup )** ###

  `$ sudo cp /opt/csi/etc/aws/vagrant.yaml.EXAMPLE /opt/csi/etc/aws/vagrant.yaml`
  
  # Populate the necessary parameters in /opt/csi/etc/aws/vagrant.yaml and then execute the following:

  `$ cd /opt/csi && sudo ./install.sh aws`

### **Install in VirtualBox (Recommended if Testing in an Air Gapped Network)** ###
  # Without GUI:

 `$ cd /opt/csi && sudo ./install.sh virtualbox`

  # With GUI:

  ```
  $ cd /opt/csi && sudo ./install.sh virtualbox-gui
  $ sudo vagrant ssh
  ubuntu@csi:~$ sudo passwd ubuntu <create new password and authenticate in lxdm VirtualBox window>
  ```
  
  # Log into the GUI

  open terminator console application (found within the lxde menu => System Tools => Terminator)

  ```
  $ csi
  csi[v0.1.90]:001 » CSI.help
  csi[v0.1.90]:002 » CSI::Plugins.help
  csi[v0.1.90]:003 » CSI::WWW.help
  csi[v0.1.90]:004 » CSI::WWW::Google.help
  csi[v0.1.90]:005 » CSI::WWW::Google.open(:browser_type => :chrome)
  csi[v0.1.90]:006 » CSI::WWW::Google.search(:q => 'site:github.com')
  csi[v0.1.90]:007 » $browser = CSI::Plugins::TransparentBrowser.close(:browser_obj => $browser)
  ```

  it's important to note that some modules may require root access to run properly (e.g. CSI::Plugins::NmapIt when certain flags are set)

  ```
  # csi
  csi[v0.1.90]:1 » CSI::Plugins::NmapIt.help
  USAGE:
          CSI::Plugins::NmapIt.port_scan do |nmap|
            puts nmap.public_methods
            nmap.syn_scan = true
            nmap.service_scan = true
            nmap.os_fingerprint = true
            nmap.verbose = true
            nmap.ports = [1..1024,1337]
            nmap.targets = '127.0.0.1'
            nmap.xml = '/tmp/nmap_port_scan_res.xml'
          end

          CSI::Plugins::NmapIt.authors
        
  => nil
  csi[v0.1.90]:2 » CSI::Plugins::NmapIt.port_scan do |nmap|
  csi[v0.1.90]:2 *   nmap.syn_scan = true
  csi[v0.1.90]:2 *   nmap.service_scan = true
  csi[v0.1.90]:2 *   nmap.os_fingerprint = true
  csi[v0.1.90]:2 *   nmap.ports = [1..1024,1337]
  csi[v0.1.90]:2 *   nmap.targets = '127.0.0.1'
  csi[v0.1.90]:2 * end  

  Starting Nmap 7.12 ( https://nmap.org ) at 2016-08-02 18:13 MDT
  Nmap scan report for localhost (127.0.0.1)
  Host is up (0.00012s latency).
  ...
  ```

  because pry is used in csi we can record and replay automation session :)

  ```
  csi[v0.1.90]:3 » hist
  1: CSI::Plugins::NmapIt.help
  2: CSI::Plugins::NmapIt.port_scan do |nmap|
  3:   nmap.syn_scan = true
  4:   nmap.service_scan = true
  5:   nmap.os_fingerprint = true
  6:   nmap.ports = [1..1024,1337]
  7:   nmap.targets = '127.0.0.1'
  8: end
  csi[v0.1.90]:4 » hist -r 2..8

  Starting Nmap 7.12 ( https://nmap.org ) at 2016-08-02 18:17 MDT
  Nmap scan report for localhost (127.0.0.1)
  Host is up (0.00012s latency).
  ...
  ```

### **Begin Prototyping Automation in AWS EC2 and VirtualBox => (Coming soon - Docker and ElasticBeanstalk)** ###
  # In order to Leverage Core Modules in Your Own CSI Environments:

  ```
  $ cd /opt/csi && sudo vagrant ssh
  ubuntu@csi:~$ csi
  csi[v0.1.90]:001 » CSI.help
  ```
  
Install Gem Only (Expert):

  ```
  $ sudo su -
  # cd /opt/csi
  # ./install.sh ruby-gem
  # exit
  $ cd /opt/csi && csi
  csi[v0.1.90]:001 » CSI.help
  ```

  # Please note if the ruby gem, 'pg' fails to build in OSX, be sure to install Macports & the postgresql96-server package:

  ```
  $ sudo port install postgresql96-server
  $ sudo su -
  # cd /opt/csi && ./install.sh ruby-gem
  # exit
  $ cd /opt/csi && csi
  csi[v0.1.90]:001 » CSI.help
  ```
