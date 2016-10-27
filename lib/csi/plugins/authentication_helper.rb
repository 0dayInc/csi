# frozen_string_literal: true
require 'highline/import'

module CSI
  module Plugins
    # This plugin is used to assist in masking a password when entered in via 
    # STDIN to prevent would-be shoulder surfers from obtaining password 
    # information.  This plugin is useful when demonstrating the functionality 
    # of other SP plugins/modules.
    module AuthenticationHelper
      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.mask_password
      public
      def self.mask_password
        pass = HighLine.new.ask('Password: ') {|q| q.echo = "\*" }
        return pass.to_s.scrub.chomp
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
          #{self}.mask_password

          #{self}.authors
        }
      end
    end
  end
end
