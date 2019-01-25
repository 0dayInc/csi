# frozen_string_literal: true

module CSI
  # This file, using the autoload directive loads SP reports
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module FFI
    # autoload :Sock, 'csi/ffi/sock'

    # Display a List of Every CSI Report

    public_class_method def self.help
      constants.sort
    end
  end
end
