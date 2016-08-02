require 'logger'

module CSI
  module Plugins
    # This plugin is used to instantiate a CSI logger with a custom message format

    module CSILogger
      # Supported Method Parameters::
      # CSI::Plugins::CSILogger.create(
      #)
      public
      def self.create(opts={})
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"

        logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{severity}] #{msg}\n"
        end

        return logger
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = 'AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        '
        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          logger = #{self}.create()
         #{self}.authors
        }
      end
    end
  end
end
