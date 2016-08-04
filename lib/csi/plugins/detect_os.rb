require 'os'

module CSI
  module Plugins
    # This plugin converts images to readable text
    module DetectOS
      # Supported Method Parameters::
      # CSI::Plugins::DetectOS.type
      public
      def self.type
        return :linux if OS.linux?
        return :osx if OS.osx?
        return :cygwin if OS.cygwin?
        return :windows if OS.windows?
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = %Q{AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        }

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          #{self}.type

          #{self}.authors
        }
      end
    end
  end
end
