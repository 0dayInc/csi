# frozen_string_literal: true
module CSI
  # This file, using the autoload directive loads SP Sinatra web applications
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module WebApp
    autoload :SCAPM, 'csi/web_app/scapm'

    # Display a List of Every CSI Web Application
    public
    def self.help
      return self.constants.sort
    end
  end
end
