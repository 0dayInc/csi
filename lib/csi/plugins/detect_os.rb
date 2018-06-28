# frozen_string_literal: true

require 'os'

module CSI
  module Plugins
    # This plugin converts images to readable text
    module DetectOS
      # Supported Method Parameters::
      # CSI::Plugins::DetectOS.type

      public_class_method def self.type
        return :cygwin if OS.cygwin?
        return :linux if OS.linux?
        return :osx if OS.osx?
        return :windows if OS.windows?
      rescue => e
        return e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          #{self}.type

          #{self}.authors
        "
      end
    end
  end
end
