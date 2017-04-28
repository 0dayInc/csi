# frozen_string_literal: true

module CSI
  # This file, using the autoload directive loads SP plugins
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module Plugins
    autoload :Android, 'csi/plugins/android'
    autoload :AnsibleVault, 'csi/plugins/ansible_vault'
    autoload :AuthenticationHelper, 'csi/plugins/authentication_helper'
    autoload :BasicAuth, 'csi/plugins/basic_auth'
    autoload :BeEF, 'csi/plugins/beef'
    autoload :BurpSuite, 'csi/plugins/burp_suite'
    autoload :CreditCard, 'csi/plugins/credit_card'
    autoload :CSILogger, 'csi/plugins/csi_logger'
    autoload :DAOLDAP, 'csi/plugins/dao_ldap'
    autoload :DAOMongo, 'csi/plugins/dao_mongo'
    autoload :DAOPostgres, 'csi/plugins/dao_postgres'
    autoload :DAOSQLite3, 'csi/plugins/dao_sqlite3'
    autoload :DetectOS, 'csi/plugins/detect_os'
    autoload :FileFu, 'csi/plugins/file_fu'
    autoload :Git, 'csi/plugins/git'
    autoload :HackerOne, 'csi/plugins/hacker_one'
    autoload :IBMAppscan, 'csi/plugins/ibm_appscan'
    autoload :IPInfo, 'csi/plugins/ip_info'
    autoload :Jenkins, 'csi/plugins/jenkins'
    autoload :JSONPathify, 'csi/plugins/json_pathify'
    autoload :MailAgent, 'csi/plugins/mail_agent'
    autoload :Metasploit, 'csi/plugins/metasploit'
    autoload :NexposeVulnScan, 'csi/plugins/nexpose_vuln_scan'
    autoload :NmapIt, 'csi/plugins/nmap_it'
    autoload :OAuth2, 'csi/plugins/oauth2'
    autoload :OCR, 'csi/plugins/ocr'
    autoload :OpenVASVulnScan, 'csi/plugins/openvas_vuln_scan'
    autoload :OwaspZap, 'csi/plugins/owasp_zap'
    autoload :Packet, 'csi/plugins/packet'
    autoload :PDFParse, 'csi/plugins/pdf_parse'
    autoload :RabbitMQHole, 'csi/plugins/rabbit_mq_hole'
    autoload :Serial, 'csi/plugins/serial'
    autoload :Shodan, 'csi/plugins/shodan'
    autoload :SlackClient, 'csi/plugins/slack_client'
    autoload :Spider, 'csi/plugins/spider'
    autoload :ThreadPool, 'csi/plugins/thread_pool'
    autoload :TransparentBrowser, 'csi/plugins/transparent_browser'
    autoload :UTF8, 'csi/plugins/utf8'

    # Display a List of Every CSI Plugin

    public

    def self.help
      constants.sort
    end
  end
end
