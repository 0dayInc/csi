# frozen_string_literal: true

module CSI
  # This file, using the autoload directive loads SP reports
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module Reports
    # autoload :HTML, 'csi/reports/html'
    # autoload :JSON, 'csi/reports/json'
    # autoload :PDF, 'csi/reports/pdf'
    autoload :SCAPM, 'csi/reports/scapm'
    # autoload :XML, 'csi/reports/xml'

    # Display a List of Every CSI Report

    public_class_method def self.help
      constants.sort
    end
  end
end
