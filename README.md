![CSI](https://github.com/ninp0/csi/blob/master/third_party/virtualbox-gui_wallpaper.jpg)

### **Table of Contents** ###
1. [Intro](#intro)
2. [Call to Arms](#call-to-arms)
3. [Clone CSI](#clone-csi)
4. [Supported OSs and Deployment Scenarios](#supported-oss-and-deployment-scenarios)
5. [CSI Installation Dependencies](#csi-installation-dependencies)
6. [Installation](#installation)
7. [General Usage](#general-usage)
8. [CSI Modules Can be Mixed and Matched to Produce Your Own Drivers](#csi-modules-can-be-mixed-and-matched-to-produce-your-own-drivers)


### **Intro** ###
It's easy to agree that while corporate automation is a collection of proprietary source code, the core modules used to produce automated solutions should be open for all eyes to continuously promote trust and innovation...broad collaboration is key to any automation framework's success, particularly in the cyber security arena.  Introducing CSI (Continuous Security Integration) - a security automation framework that aims to stand on the shoulders of security giants.  If a picture is worth a thousand words, then a video must be worth at least a million...let's start out by planting a million seeds in your mind:

[![Continuous Security Integration: Basics of Building Your Own Security Automation ](https://i.ytimg.com/vi/MLSqd5F-Bjw/0.jpg)](https://youtu.be/MLSqd5F-Bjw)



### **Call to Arms** ###
If you're willing to provide access to commercial security tools (e.g. Rapid7's Nexpose, Tenable Nessus, QualysGuard, HP WebInspect, IBM Appscan, etc) please PM me as this will continue to promote CSIs interoperability w/ industry-recognized security tools moving forward.  Lastly, this project accepts donations, so if you want to see this thing blow the door off the hinges, please donate!!! 

[![Click here to lend your support to CSI and make a donation via pledgie.com](https://pledgie.com/campaigns/32329.png?skin_name=chrome)](https://pledgie.com/campaigns/32329)



### **Clone CSI** ###

 `$ sudo git clone https://github.com/ninp0/csi.git /opt/csi`



### **Supported OSs and Deployment Scenarios** ###
**Supported Operating Systems:** Ubuntu & OSX

Think of the cloned CSI repo as the root folder for your security automation...you can install CSI leveraging the following methods:

  - AWS EC2
  - Docker (Coming Soon)
  - Locally on your Box
  - VirtualBox

All installation methods are recommended :)



### **CSI Installation Dependencies** ###
  - AWS EC2 Deployment
    * Vagrant
    * AWS Account
    * Pre-Defined Public Key Pair Created in EC2
    * Pre-Defined Security Group
    * VPC & Subnet
    * Registered Domain Name (Preferred - CSI attempts to register domain TLS certs w/ Let's Encrypt)

  - Docker (Coming Soon)
    * Vagrant
    * Docker

  - Locally on your Box as a Ruby Gem
    * Macports (if OS == OSX)
    * rvm
    * rsync
    * Ansible

    * postgresql dev libraries
      * Ubuntu: `$ sudo apt-get install postgresql-server-dev-all`
      * OSX: `$ sudo port install postgresql96-server`

    * libpcap dev libraries
      * Ubuntu: `$ sudo apt-get install libpcap-dev`
      * OSX: `$ sudo port install libpcap`

    * ImageMagick 
      * Ubuntu: `$ sudo apt-get install libmagickwand-dev imagemagick`
      * OSX: `$ sudo port install imagemagick`

    * Tesseract (OCR) ;)
      * Ubuntu: `$ sudo apt-get install tesseract-ocr-all`
      * OSX: `$ sudo port install tesseract`

  - VirtualBox Deployment
    * Vagrant
    * Oracle VirtualBox
    * Oracle VM VirtualBox Extension Pack



### **Installation** ###
#### **Install CSI in AWS EC2** ####
  # Be Sure to Take a Look at the AWS Acceptable Use Policy: https://aws.amazon.com/aup
  ```
  $ sudo cp /opt/csi/etc/aws/vagrant.yaml.EXAMPLE /opt/csi/etc/aws/vagrant.yaml
  $ sudo cp /opt/csi/etc/letsencrypt/vagrant.yaml.EXAMPLE /opt/csi/etc/letsencrypt/vagrant.yaml
  ```
  
  # Populate the necessary parameters in BOTH vagrant.yaml files and then execute the following:

  `$ cd /opt/csi && sudo ./install.sh aws`



#### **Install in Docker Container (Coming Soon)** ####



#### **Install Locally on your Box** ####

  ```
  $ sudo su -
  # cd /opt/csi
  # ./install.sh ruby-gem
  # exit
  $ cd /opt/csi && csi
  csi[v0.1.269]:001 » CSI.help
  ```

  # Please note if the ruby gem, 'pg' fails to build in OSX, be sure to install Macports & the postgresql96-server package:

  ```
  $ sudo port install postgresql96-server
  $ sudo su -
  # cd /opt/csi && ./install.sh ruby-gem
  # exit
  $ cd /opt/csi && csi
  csi[v0.1.269]:001 » CSI.help
  ```



#### **Install in VirtualBox (Recommended if Testing in an Air Gapped Network)** ####
  # Without GUI:

  ```
  $ sudo cp /opt/csi/etc/virtualbox/vagrant.yaml.EXAMPLE /opt/csi/etc/virtualbox/vagrant.yaml
  $ cd /opt/csi && sudo ./install.sh virtualbox
  ```

  # With GUI:

  ```
  $ sudo cp /opt/csi/etc/virtualbox/vagrant.yaml.EXAMPLE /opt/csi/etc/virtualbox/vagrant.yaml
  $ cd /opt/csi && sudo ./install.sh virtualbox-gui
  $ sudo vagrant ssh
  ubuntu@csi:~$ sudo passwd ubuntu <create new password and authenticate in lxdm VirtualBox window>
  ```
  
  # Log into the GUI

  open terminator console application (found within the lxde menu => System Tools => Terminator)

  


### **General Usage** ###
  It all starts in the csi prototyping driver:
  ```
  $ csi
  csi[v0.1.269]:001 » CSI.help
  csi[v0.1.269]:002 » CSI::Plugins.help
  csi[v0.1.269]:003 » CSI::WWW.help
  csi[v0.1.269]:004 » CSI::WWW::Google.help
  csi[v0.1.269]:005 » CSI::WWW::Google.open(:browser_type => :chrome)
  csi[v0.1.269]:006 » CSI::WWW::Google.search(:q => 'site:github.com')
  csi[v0.1.269]:007 » CSI::WWW::Google.search(:q => 'site:github.com inurl:"ninp0/csi"')
  csi[v0.1.269]:008 » CSI::WWW::Google.close
  ```

  You say you want to write your own custom security tests for your own website using a mitm proxy?  That's cool chum, here's a few ways:
  
  ```
  csi[v0.1.269]:1 » CSI::Plugins::TransparentBrowser.help
    USAGE:
      ...

  csi[v0.1.269]:2 » CSI::Plugins::BurpSuite.help
    USAGE:
      ...

  csi[v0.1.269]:3 » CSI::Plugins::OwaspZapIt.help
    USAGE:
      ...
  ```
  If you want more context around using CSI::Plugins::TransparentBrowser for your own browser automation, checkout the CSI::WWW modules (they were all built using CSI::Plugins::TransparentBrowser): https://github.com/ninp0/csi/tree/master/lib/csi/www

  It's important to note that some modules may require root access to run properly (e.g. CSI::Plugins::NmapIt when certain flags are set)

  ```
  # csi
  csi[v0.1.269]:1 » CSI::Plugins::NmapIt.help
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
  csi[v0.1.269]:2 » CSI::Plugins::NmapIt.port_scan do |nmap|
  csi[v0.1.269]:2 *   nmap.syn_scan = true
  csi[v0.1.269]:2 *   nmap.service_scan = true
  csi[v0.1.269]:2 *   nmap.os_fingerprint = true
  csi[v0.1.269]:2 *   nmap.ports = [1..1024,1337]
  csi[v0.1.269]:2 *   nmap.targets = '127.0.0.1'
  csi[v0.1.269]:2 * end  

  Starting Nmap 7.12 ( https://nmap.org ) at 2016-08-02 18:13 MDT
  Nmap scan report for localhost (127.0.0.1)
  Host is up (0.00012s latency).
  ...
  ```

  Since the Pry gem is core to the CSI prototyping driver, we can record and replay automation sessions \o/--(Woohoo...Ya!!!)

  ```
  csi[v0.1.269]:3 » hist
  1: CSI::Plugins::NmapIt.help
  2: CSI::Plugins::NmapIt.port_scan do |nmap|
  3:   nmap.syn_scan = true
  4:   nmap.service_scan = true
  5:   nmap.os_fingerprint = true
  6:   nmap.ports = [1..1024,1337]
  7:   nmap.targets = '127.0.0.1'
  8: end
  csi[v0.1.269]:4 » hist -r 2..8

  Starting Nmap 7.12 ( https://nmap.org ) at 2016-08-02 18:17 MDT
  Nmap scan report for localhost (127.0.0.1)
  Host is up (0.00012s latency).
  ...
  ```

  At this point you may be thinkin', "there's only a csi prototyping driver to run automation?"  Definitely no, there's much more!  The CSI prototyping driver was used to create these other drivers: https://github.com/ninp0/csi/tree/master/bin
  
  Use these examples to build your own drivers!  If they're awesome, submit a pull request, pass our sanity checks, and we'll merge it for the community to use:

  ```
  $ csi<tab><tab>
  csi                             csi_ibm_appscan_enterprise      csi_jenkins_useradd             csi_serial_check_voicemail
  csi_active_scan_burp_suite_pro  csi_jenkins_install_plugin      csi_msf_postgres_login          csi_serial_qualcomm_commands
  csi_autoinc_version             csi_jenkins_thinBackup_aws_s3   csi_nexpose                     csi_web_app_scapm
  csi_aws_describe_resources      csi_jenkins_update_plugins      csi_scapm 
  ```

  Type the name of each driver above individually for command usage.



### **CSI Modules Can be Mixed and Matched to Produce Your Own Drivers** ###
![CSI](https://github.com/ninp0/csi/blob/master/documentation/CSI_Driver_Arch.png)
  ```
  $ csi
  csi[v0.1.269]:1 » CSI.help
  => [:ExploitModules, :Plugins, :Reports, :SCAPM, :VERSION, :WWW, :WebApp]

  csi[v0.1.269]:2 » CSI::Plugins.help
   => [:AWSACM,
    :AWSAPIGateway,
    :AWSApplicationAutoScaling,
    :AWSApplicationDiscoveryService,
    :AWSAutoScaling,
    :AWSCloudFormation,
    :AWSCloudFront,
    :AWSCloudHSM,
    :AWSCloudSearch,
    :AWSCloudSearchDomain,
    :AWSCloudTrail,
    :AWSCloudWatch,
    :AWSCloudWatchEvents,
    :AWSCloudWatchLogs,
    :AWSCodeCommit,
    :AWSCodeDeploy,
    :AWSCodePipeline,
    :AWSCognitoIdentity,
    :AWSCognitoIdentityProvider,
    :AWSCognitoSync,
    :AWSConfigService,
    :AWSDataPipeline,
    :AWSDatabaseMigrationService,
    :AWSDeviceFarm,
    :AWSDirectConnect,
    :AWSDirectoryService,
    :AWSDynamoDB,
    :AWSDynamoDBStreams,
    :AWSEC2,
    :AWSECR,
    :AWSECS,
    :AWSEFS,
    :AWSEMR,
    :AWSElastiCache,
    :AWSElasticBeanstalk,
    :AWSElasticLoadBalancing,
    :AWSElasticLoadBalancingV2,
    :AWSElasticTranscoder,
    :AWSElasticsearchService,
    :AWSFirehose,
    :AWSGameLift,
    :AWSGlacier,
    :AWSIAM,
    :AWSImportExport,
    :AWSInspector,
    :AWSIoT,
    :AWSIoTDataPlane,
    :AWSKMS,
    :AWSKinesis,
    :AWSKinesisAnalytics,
    :AWSLambda,
    :AWSLambdaPreview,
    :AWSMachineLearning,
    :AWSMarketplaceCommerceAnalytics,
    :AWSMarketplaceMetering,
    :AWSOpsWorks,
    :AWSRDS,
    :AWSRedshift,
    :AWSRoute53,
    :AWSRoute53Domains,
    :AWSS3,
    :AWSSES,
    :AWSSNS,
    :AWSSQS,
    :AWSSSM,
    :AWSSTS,
    :AWSSWF,
    :AWSServiceCatalog,
    :AWSSimpleDB,
    :AWSSnowball,
    :AWSStorageGateway,
    :AWSSupport,
    :AWSWAF,
    :AWSWorkspaces,
    :AnsibleVault,
    :AuthenticationHelper,
    :BasicAuth,
    :BurpSuite,
    :CSILogger,
    :DAOLDAP,
    :DAOMongo,
    :DAOPostgres,
    :DAOSQLite3,
    :DetectOS,
    :FileFu,
    :Git,
    :IBMAppscan,
    :IPInfo,
    :JSONPathify,
    :Jenkins,
    :MailAgent,
    :Metasploit,
    :NexposeVulnScan,
    :NmapIt,
    :OAuth2,
    :OCR,
    :OpenVASVulnScan,
    :OwaspZapIt,
    :PDFParse,
    :RabbitMQHole,
    :Serial,
    :SlackClient,
    :ThreadPool,
    :TransparentBrowser,
    :UTF8]

  csi[v0.1.269]:3 » CSI::WWW.help
  => [:Bing, :Checkip, :Duckduckgo, :Google, :Hackerone, :Pastebin, :Synack, :Torch, :Youtube]
  ```

  It's wise to rebuild csi often as this repo has numerous releases/week:
  ```
  $ sudo su -
  # cd /opt/csi && ./build_csi_gem.sh
  ```


  I hope you enjoy CSI and remember...ensure you always have permission prior to carrying out any sort of automated hacktivities.  Now - go automate all the things!
