require 'yaml'
module CSI
  module Plugins
    # CSI module used to interact w/ Android Devices
    module Android
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb(
      #   :adb_path => 'required - path to adb binary',
      #   :command => 'adb command to execute'
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        command = opts[:command].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          adb_response = `#{adb_path} #{command}` 

          return adb_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.open_app(
      #   :adb_path => 'required - path to adb binary',
      #   :intent => 'required - application intent to run (i.e. open an android app)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.open_app(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        intent = opts[:intent].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          app_response = `#{adb_path} am start -n #{intent}/#{intent}.MainActivity` 

          return app_response
        rescue => e
          return e.message
        end
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

          adb_response = #{self}.adb(
            :adb_path => 'required - path to adb binary',
            :command => 'adb command to execute'
            :as_root => 'optional - boolean (defaults to false)',
          )

          intent = #{self}.open_app(
            :adb_path => 'required - path to adb binary',
            :intent => 'required - application intent to run (i.e. open an android app)',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.authors
        }
      end
    end
  end
end
