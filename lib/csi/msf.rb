# frozen_string_literal: true
module CSI
  # This file, using the autoload directive loads SP exploit modules
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module MSF
    autoload :PostgresLogin, 'csi/msf/postgres_login'

    # Display a List of Every CSI Exploit Module
    public
    def self.help
      return self.constants.sort
    end
  end
end
