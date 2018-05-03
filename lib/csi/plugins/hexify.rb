# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin was created to generate UTF-8 characters for fuzzing
    module Hexify
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # short_int = CSI::Plugins::Hexify.short_int(
      #   int: 'required = integer ranging from 0-65535 to convert to short_int hex bytes'
      # )

      public

      def self.short_int(opts = {})
        # TODO: big endian and little endian parameters
        int = opts[:int].to_i
        short_int = [int].pack('S>').unpack('H*')[0].scan(/../).map{|h| '\x'+h }.join
      rescue => e
        return e.message
      end

      # Supported Method Parameters::
      # long_int = CSI::Plugins::Hexify.long_int(
      #   int: 'required = integer ranging from 0-2147483647 to convert to long_int hex bytes'
      # )

      public

      def self.long_int(opts = {})
        # TODO: big endian and little endian parameters
        int = opts[:int].to_i
        long_int = [int].pack('L>').unpack('H*')[0].scan(/../).map{|h| '\x'+h }.join
      rescue => e
        return e.message
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          short_int = CSI::Plugins::Hexify.short_int(
            int: 'required = integer ranging from 0-65535 to convert to short_int hex bytes'
          )

          long_int = #{self}.long_int(
            int: 'required = integer ranging from 0-2147483647 to convert to long_int hex bytes'
          )
        "
      end
    end
  end
end
