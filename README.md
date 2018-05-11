![CSI](https://github.com/ninp0/csi/blob/master/documentation/virtualbox-gui_wallpaper.jpg)

### **Table of Contents** ###
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
  * [Deploy in AWS EC2](#deploy-in-aws-ec2)
  * [Deploy in Docker Container](#deploy-in-docker-container)
  * [Deploy in VirtualBox](#deploy-in-virtualbox)
  * [Deploy in VMware](#deploy-in-vmware)
- [General Usage](#general-usage)
- [Driver Documentation](#driver-documentation)


### **Call to Arms** ###
If you're willing to provide access to commercial security tools (e.g. Rapid7's Nexpose, Tenable Nessus, QualysGuard, HP WebInspect, IBM Appscan, etc) please PM us as this will continue to promote CSIs interoperability w/ industry-recognized security tools moving forward.


### **Intro** ###
#### **Why CSI** ####
It's easy to agree that while corporate automation is a collection of proprietary source code, the core modules used to produce automated solutions should be open for all eyes to continuously promote trust and innovation...broad collaboration is key to any automation framework's success, particularly in the cyber security arena.  

#### **How CSI Works** ####
Leveraging various pre-built modules and the csi prototyper, you can mix-and-match modules to test, record, replay, and rollout your own custom security automation packages known as, "drivers."  The fastest way to getting rolling w/ csi is to deploy a pre-built Kali Rolling box we built w/ Packer.  This is a special deployment of Kali Rolling - WORKING rollouts of AFL w/ QEMU instrumentation ready-to-go, PEDA (Python Exploit Development Assistance for GDB), OpenVAS, latest clone of Metasploit, Arachni, Jenkins (w/ pre-canned jobs and the ability to create your own prior to deployment aka User-Land!), etc.  These are just some of the numerous security and CI/CD tools made available for your convenience...updated on a daily basis.  CSI driver integration is made to be seamless w/ OS dependencies already installed.  This is all made available for architectures such as AWS, Docker, VirtualBox, and/or VMware.  See the [Deploy](#deploy) section for more details.

#### **What is CSI** ####
CSI (Continuous Security Integration) is an open security automation framework that aims to stand on the shoulders of security giants, promoting trust and innovation.  Build your own custom automation drivers freely and easily using pre-built modules.  If a picture is worth a thousand words, then a video must be worth at least a million...let's start out by planting a million seeds in your mind:

#### **Creating an OWASP ZAP Scanning Driver Leveraging the csi Prototyper** ####
[![Continuous Security Integration: Basics of Building Your Own Security Automation ](https://i.ytimg.com/vi/MLSqd5F-Bjw/0.jpg)](https://youtu.be/MLSqd5F-Bjw)

#### **CSI Modules Can be Mixed and Matched to Produce Your Own Tools** ####
Also known as, "Drivers" CSI can produce all sorts of useful tools by mixing and matching modules.
![CSI](https://github.com/ninp0/csi/blob/master/documentation/CSI_Driver_Arch.png)



### **Clone CSI** ###
Certain Constraints Mandate CSI be Installed in /csi:
 `$ sudo git clone https://github.com/ninp0/csi.git /csi`



### **Deploy** ###
#### **Basic Installation Dependencies** ###
- Latest Version of Vagrant: https://www.vagrantup.com/downloads.html
- Packer: https://www.packer.io/downloads.html (If you contribute to the Kali Rolling Box hosted on https://app.vagrantup.com/csi/boxes/kali_rolling)

#### **Deploy in AWS EC2** ####
[AWS EC2 Quick-Start](https://github.com/ninp0/csi/wiki/Deploy-CSI-in-AWS-EC2-on-Top-of-Kali-Rolling)



#### **Deploy in Docker Container** ####
[Docker Quick-Start](https://github.com/ninp0/csi/wiki/Deploy-CSI-in-Docker-Container)


#### **Deploy in VirtualBox** ####
[VirtualBox Quick-Start](https://github.com/ninp0/csi/wiki/Deploy-CSI-in-VirtualBox-on-Top-of-Kali-Rolling)
  

#### **Deploy in VMware** ####
[VMware Quick-Start](https://github.com/ninp0/csi/wiki/Deploy-CSI-in-VMware-on-Top-of-Kali-Rolling)



### **General Usage** ###
[General Usage Quick-Start](https://github.com/ninp0/csi/wiki/General-CSI-Usage)

It's wise to rebuild csi often as this repo has numerous releases/week (unless you're in the Kali box, then it's handled for you daily in the Jenkins job called, "selfupdate-csi":
  ```
  $ /csi/vagrant/provisioners/csi.sh && csi
  csi[v0.2.865]:001 >>> CSI.help
  ```


### **Driver Documentation** ###
[For a list of existing drivers and their usage](https://github.com/ninp0/csi/wiki/CSI-Driver-Documentation)



I hope you enjoy CSI and remember...ensure you always have permission prior to carrying out any sort of hacktivities.  Now - go hacktivate all the things!
