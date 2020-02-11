![CSI](https://github.com/0dayinc/csi/blob/master/documentation/virtualbox-gui_wallpaper.jpg)

### **Table of Contents** ###
- [Keep Us Caffeinated](#keep-us-caffeinated)
- [Call to Arms](#call-to-arms)
- [Intro](#intro)
  * [Why CSI](#why-csi)
  * [How CSI Works](#how-csi-works)
  * [What is CSI](#what-is-csi)
  * [CSI Modules Can be Mixed and Matched to Produce Your Own Tools](#csi-modules-can-be-mixed-and-matched-to-produce-your-own-tools)
  * [Creating an OWASP ZAP Scanning Driver Leveraging the csi Prototyper](#creating-an-owasp-zap-scanning-driver-leveraging-the-csi-prototyper)
- [Clone CSI](#clone-csi)
- [Deploy](#deploy)
  * [Basic Installation Dependencies](#basic-installation-dependencies)
  * [Install Locally on Host OS](#install-locally-on-host-os)
  * [Deploy in AWS EC2](#deploy-in-aws-ec2)
  * [Deploy in Docker Container](#deploy-in-docker-container)
  * [Deploy in VirtualBox](#deploy-in-virtualbox)
  * [Deploy in VMware](#deploy-in-vmware)
  * [Deploy in vSphere](#deploy-in-vsphere)
- [General Usage](#general-usage)
- [Driver Documentation](#driver-documentation)
- [Merchandise](#merchandise)


### **Keep Us Caffeinated** ###
If you've found this framework useful and you're either not in a position to donate or simply interested in us cranking out as many features as possible, we invite you to take a brief moment to keep us caffeinated:

[![Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoff.ee/0dayinc)

### **Call to Arms** ###
If you're willing to provide access to commercial security tools (e.g. Rapid7's Nexpose, Tenable Nessus, QualysGuard, HP WebInspect, IBM Appscan, etc) please PM us as this will continue to promote CSIs interoperability w/ industry-recognized security tools moving forward.  Additionally if you want to contribute to this framework's success, check out our [How to Contribute](https://github.com/0dayInc/csi/blob/master/CONTRIBUTING.md).  Lastly, we accept [donations](https://cash.me/$fundcsi).


### **Intro** ###
#### **What is CSI** ####
CSI (Continuous Security Integration) is an open security automation framework that aims to stand on the shoulders of security giants, promoting trust and innovation.  Build your own custom automation drivers freely and easily using pre-built modules.  If a picture is worth a thousand words, then a video must be worth at least a million...let's begin by planting a million seeds in your mind:

#### **Creating an OWASP ZAP Scanning Driver Leveraging the csi Prototyper** ####
[![Continuous Security Integration: Basics of Building Your Own Security Automation ](https://i.ytimg.com/vi/MLSqd5F-Bjw/0.jpg)](https://youtu.be/MLSqd5F-Bjw)

#### **Why CSI** ####
It's easy to agree that while corporate automation is a collection of proprietary source code, the core modules used to produce automated solutions should be open for all eyes to continuously promote trust and innovation...broad collaboration is key to any automation framework's success, particularly in the cyber security arena.  

#### **How CSI Works** ####
Leveraging various pre-built modules and the csi prototyper, you can mix-and-match modules to test, record, replay, and rollout your own custom security automation packages known as, "drivers."  

The fastest way to get rolling w/ csi is to deploy a pre-built Kali Rolling box, available on [Vagrant Cloud](https://app.vagrantup.com/csi/boxes/kali_rolling).  This is a special deployment of Kali Rolling - WORKING rollouts of AFL w/ QEMU instrumentation ready-to-go, PEDA (Python Exploit Development Assistance for GDB), OpenVAS, latest clone of Metasploit, Arachni, Jenkins (w/ pre-canned jobs and the ability to create your own prior to deployment aka User-Land!), etc.  These are just some of the numerous security and CI/CD tools made available for your convenience...updated on a daily basis.  

An instance of [DefectDojo](http://defectdojo.readthedocs.io/en/latest/) is stood up on the box to facilitate common security tools integration, resulting in a centralized place to manage scan results, track the lifecycle of vulnerabilities, and analyze trends via metrics and reporting!  CSI driver integration is made to be seamless w/ OS dependencies already installed.  This is all made available for architectures such as AWS, Docker, VirtualBox, and/or VMware.  See the [Deploy](#deploy) section for more details.

#### **CSI Modules Can be Mixed and Matched to Produce Your Own Tools** ####
Also known as, "Drivers" CSI can produce all sorts of useful tools by mixing and matching modules.
![CSI](https://github.com/0dayinc/csi/blob/master/documentation/CSI_Driver_Arch.png)



### **Clone CSI** ###
Certain Constraints Mandate CSI be Installed in /opt/csi:
 `$ sudo git clone https://github.com/0dayinc/csi.git /opt/csi`



### **Deploy** ###
#### **Basic Installation Dependencies** ###
- Latest Version of Vagrant: https://www.vagrantup.com/downloads.html
- Latest Version of Vagrant VMware Utility (if using VMware): https://www.vagrantup.com/vmware/downloads.html
- Packer: https://www.packer.io/downloads.html (If you contribute to the Kali Rolling Box hosted on https://app.vagrantup.com/csi/boxes/kali_rolling)

#### **Install Locally on Host OS** ####
[Instructions](https://gist.github.com/ninp0/613696fbf2ffda01b02706a89bef7491)


#### **Deploy in AWS EC2** ####
[Instructions](https://gist.github.com/ninp0/ba9698b7ca5a7696abf37a579097a2f2)


#### **Deploy in Docker Container** ####
Not Quite Available - Coming Soon


#### **Deploy in VirtualBox** ####
[Instructions](https://gist.github.com/ninp0/f01c4f129a34684f30f5cd2935c0f0d8)
  

#### **Deploy in VMware** ####
[Instructions](https://gist.github.com/ninp0/2e97f1f34c956e90294f214e1edd2ffb)


#### **Deploy in vSphere** ####
[Instructions](https://gist.github.com/ninp0/f1baf4fcd4ae9d23ae35ed7a7d083ae9)



### **General Usage** ###
[General Usage Quick-Start](https://github.com/0dayinc/csi/wiki/General-CSI-Usage)

It's wise to rebuild csi often as this repo has numerous releases/week (unless you're in the Kali box, then it's handled for you daily in the Jenkins job called, "selfupdate-csi":
  ```
  $ /opt/csi/vagrant/provisioners/csi.sh && csi
  csi[v0.3.880]:001 >>> CSI.help
  ```


### **Driver Documentation** ###
[For a list of existing drivers and their usage](https://github.com/0dayinc/csi/wiki/CSI-Driver-Documentation)



I hope you enjoy CSI and remember...ensure you always have permission prior to carrying out any sort of hacktivities.  Now - go hackomate all the things!

### **Merchandise** ###

[![Coffee Mug](https://image.spreadshirtmedia.com/image-server/v1/products/T949A2PA1998PT25X7Y0D1020472684FS8982/views/3,width=650,height=650,appearanceId=2,backgroundColor=f6f6f6,crop=detail,modelId=1333,version=1546851285/https0dayinccom.jpg)](https://shop.spreadshirt.com/0day/redfingerprint-A5c3e49cd1cbf3a0b9596ae58?productType=949&appearance=2&size=29)

[![Womens Off the Air Hoodie](https://image.spreadshirtmedia.com/image-server/v1/products/T444A2PA801PT17X165Y17D1020472921FS3041/views/1,width=650,height=650,appearanceId=2,backgroundColor=f6f6f6/off-the-air.jpg)](https://shop.spreadshirt.com/0day/offtheair-A5c3e4bfc1cbf3a0b9597aca9?productType=444&appearance=2)

[![Red Fingerprint](https://image.spreadshirtmedia.com/image-server/v1/products/T803A2PA1648PT26X47Y0D1020472684FS6537/views/1,width=650,height=650,appearanceId=2/https0dayinccom.jpg)](https://shop.spreadshirt.com/0day/redfingerprint-A5c3e49cd1cbf3a0b9596ae58?productType=803&appearance=2&size=29)

[![0day Inc.](https://image.spreadshirtmedia.com/image-server/v1/products/T951A70PA3076PT17X0Y73D1020472680FS8515/views/1,width=650,height=650,appearanceId=70/https0dayinccom.jpg)](https://shop.spreadshirt.com/0day/0dayinc-A5c3e498cf937643162a01b5f?productType=951&appearance=70)

[![Mens Black Fingerprint Hoodie](https://image.spreadshirtmedia.com/image-server/v1/products/T111A2PA3208PT17X169Y51D1020472728FS6268/views/1,width=650,height=650,appearanceId=2/https0dayinccom.jpg)](https://shop.spreadshirt.com/0day/blackfingerprint-A5c3e49db1cbf3a0b9596b4d0?productType=111&appearance=2)
