require 'yaml'
module CSI
  module Plugins
    # CSI module used to interact w/ Android Devices
    module Android
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_sh(
      #   :adb_path => 'required - path to adb binary',
      #   :command => 'adb command to execute'
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_sh(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        command = opts[:command].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          adb_response = `#{adb_path} shell #{command}` 

          return adb_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_push(
      #   :adb_path => 'required - path to adb binary',
      #   :file => 'required - source file to push',
      #   :dest => 'required - destination path to push file',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_push(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        file = opts[:file].to_s.scrub if File.exists?(opts[:file].to_s.scrub)
        dest = opts[:dest].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          adb_push_response = `#{adb_path} push #{file} #{dest}` 

          return adb_push_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_pull(
      #   :adb_path => 'required - path to adb binary',
      #   :file => 'required - source file to pull',
      #   :dest => 'required - destination path to pull file',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_pull(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        file = opts[:file].to_s.scrub 
        dest = opts[:dest].to_s.scrub if Dir.exists?(opts[:dest].to_s.scrub)

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          adb_pull = `#{adb_path} pull #{file} #{dest}` 

          return adb_pull
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.take_screenshot(
      #   :adb_path => 'required - path to adb binary',
      #   :dest => 'required - destination path to save screenshot file',
      #   :as_root => 'optional - boolean (defaults to true)'
      # )
      public
      def self.take_screenshot(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        dest = opts[:dest].to_s.scrub

        if opts[:as_root]
          as_root = false
        else
          as_root = true
        end

        begin
          `#{adb_path} root` if as_root
          adb_pull = `#{adb_path} shell screencap -p #{dest}` 

          return adb_pull
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.list_installed_apps(
      #   :adb_path => 'required - path to adb binary',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.list_installed_apps(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          app_response = `#{adb_path} shell pm list packages` 

          return app_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.open_app(
      #   :adb_path => 'required - path to adb binary',
      #   :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.open_app(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        app = opts[:app].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          app_response = `#{adb_path} shell monkey -p #{app} -c android.intent.category.LAUNCHER 1` 

          return app_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.close_app(
      #   :adb_path => 'required - path to adb binary',
      #   :app => 'required - application app to close (i.e. open an android app returned from #list_install_apps method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.close_app(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        app = opts[:app].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{adb_path} root` if as_root
          app_response = `#{adb_path} shell am force-stop #{app}` 

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

          adb_response = #{self}.adb_sh(
            :adb_path => 'required - path to adb binary',
            :command => 'adb command to execute'
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.adb_push(
            :adb_path => 'required - path to adb binary',
            :file => 'required - source file to push',
            :dest => 'required - destination path to push file',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.adb_pull(
            :adb_path => 'required - path to adb binary',
            :file => 'required - source file to pull',
            :dest => 'required - destination path to pull file',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.take_screenshot(
            :adb_path => 'required - path to adb binary',
            :dest => 'required - destination path to save screenshot file',
            :as_root => 'optional - boolean (defaults to true)'
          )

          installed_apps = #{self}.list_installed_apps(
            :adb_path => 'required - path to adb binary',
            :as_root => 'optional - boolean (defaults to false)',
          )

          app_response = #{self}.open_app(
            :adb_path => 'required - path to adb binary',
            :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
            :as_root => 'optional - boolean (defaults to false)'
          )

          app_response = #{self}.close_app(
            :adb_path => 'required - path to adb binary',
            :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
            :as_root => 'optional - boolean (defaults to false)'
          )

          #{self}.authors
        }
      end
    end
  end
end
