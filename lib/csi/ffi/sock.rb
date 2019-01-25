# frozen_string_literal: true

require 'ffi'

module CSI
  module FFI
    # This plugin provides useful social security number capabilities
    module Sock
      # Supported Method Parameters::
      # CSI::FFI::Sock.connect(
      # )

      public_class_method def self.connect(opts = {})
        opts[:not_implemented] = 'yet'
        return opts
      rescue => e
        raise e
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
          #{self}.generate(
            count: 'required - number of SSN numbers to generate'
          )

          #{self}.authors
        "
      end
    end
  end
end
