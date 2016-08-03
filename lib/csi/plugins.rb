module CSI
  # This file, using the autoload directive loads SP plugins
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module Plugins
    autoload :AnsibleVault, 'csi/plugins/ansible_vault'
    autoload :AuthenticationHelper, 'csi/plugins/authentication_helper'
    autoload :AWSCompute, 'csi/plugins/aws_compute'
    autoload :AWSElasticBeanstalk, 'csi/plugins/aws_elastic_beanstalk'
    autoload :AWSLambda, 'csi/plugins/aws_lambda'
    autoload :AWSRoute53, 'csi/plugins/aws_route53'
    autoload :AWSS3, 'csi/plugins/aws_s3'
    autoload :AWSSTS, 'csi/plugins/aws_sts'
    autoload :BasicAuth, 'csi/plugins/basic_auth'
    autoload :BurpSuite, 'csi/plugins/burp_suite'
    autoload :CSILogger, 'csi/plugins/csi_logger'
    autoload :DAOLDAP, 'csi/plugins/dao_ldap'
    autoload :DAOMongo, 'csi/plugins/dao_mongo'
    autoload :DAOPostgres, 'csi/plugins/dao_postgres'
    autoload :DAOSQLite3, 'csi/plugins/dao_sqlite3'
    autoload :FileFu, 'csi/plugins/file_fu'
    autoload :Git, 'csi/plugins/git'
    autoload :Google, 'csi/plugins/google'
    autoload :IBMAppscan, 'csi/plugins/ibm_appscan'
    autoload :IPInfo, 'csi/plugins/ip_info'
    autoload :Jenkins, 'csi/plugins/jenkins'
    autoload :JSONPathify, 'csi/plugins/json_pathify'
    autoload :MailAgent, 'csi/plugins/mail_agent'
    autoload :Metasploit, 'csi/plugins/metasploit'
    autoload :NexposeVulnScan, 'csi/plugins/nexpose_vuln_scan'
    autoload :NmapIt, 'csi/plugins/nmap_it'
    autoload :OAuth2, 'csi/plugins/oauth2'
    autoload :OpenVASVulnScan, 'csi/plugins/openvas_vuln_scan'
    autoload :PDFParse, 'csi/plugins/pdf_parse'
    autoload :RabbitMQHole, 'csi/plugins/rabbit_mq_hole'
    autoload :Serial, 'csi/plugins/serial'
    autoload :SlackClient, 'csi/plugins/slack_client'
    autoload :ThreadPool, 'csi/plugins/thread_pool'
    autoload :TransparentBrowser, 'csi/plugins/transparent_browser'
    autoload :UTF8, 'csi/plugins/utf8'

    # Display a List of Every CSI Plugin
    public
    def self.help
      return self.constants.sort
    end
  end
end
