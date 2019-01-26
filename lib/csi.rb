# frozen_string_literal: true

require 'csi/version'

# Thank you for choosing the Continuous Security Integrtion Framework!
# Your Source for Source Code Analysis, Vulnerability Scanning, Exploitation,
# & General Security Testing in a Continuous Integration Environment
module CSI
  STDOUT.sync = true # < Ensure that all print statements output progress in realtime
  STDOUT.flush       # < Ensure that all print statements output progress in realtime
  # TODO: Determine best balance for namespace naming conventions
  autoload :AWS, 'csi/aws'
  autoload :FFI, 'csi/ffi'
  autoload :Plugins, 'csi/plugins'
  autoload :Reports, 'csi/reports'
  autoload :SCAPM, 'csi/scapm'
  autoload :WWW, 'csi/www'

  # Display Usage for the CSI Framework ~

  public_class_method def self.help
    constants.sort
  end
end
