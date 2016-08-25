require 'yaml'
module CSI
  module Plugins
    # CSI module used to interact w/ Android Devices
    module Android
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_sh(
      #   :adb_path => 'required - path to adb binary',
      #   :command => 'required - adb command to execute'
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
          app_resp = `#{adb_path} shell pm list packages` 
          app_resp_arr = app_resp.gsub("\npackage:" , "\n").split("\r\n")

          return app_resp_arr
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
      # CSI::Plugins::AndroidADB.type_string(
      #   :adb_path => 'required - path to adb binary',
      #   :string => 'required - string to type'
      # )
      public
      def self.type_string(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        string = opts[:string].to_s.scrub

        begin
          string.each_char do |char|
            case char
              when "0"
                `#{adb_path} shell input keyevent 7` 
              when "1"
                `#{adb_path} shell input keyevent 8` 
              when "2"
                `#{adb_path} shell input keyevent 9` 
              when "3"
                `#{adb_path} shell input keyevent 10` 
              when "4"
                `#{adb_path} shell input keyevent 11` 
              when "5"
                `#{adb_path} shell input keyevent 12` 
              when "6"
                `#{adb_path} shell input keyevent 13` 
              when "7"
                `#{adb_path} shell input keyevent 14` 
              when "8"
                `#{adb_path} shell input keyevent 15` 
              when "9"
                `#{adb_path} shell input keyevent 16` 
              when "*"
                `#{adb_path} shell input keyevent 17` 
              when "#"
                `#{adb_path} shell input keyevent 18` 
              when "a"
                `#{adb_path} shell input keyevent 29` 
              when "b"
                `#{adb_path} shell input keyevent 30` 
              when "c"
                `#{adb_path} shell input keyevent 31` 
              when "d"
                `#{adb_path} shell input keyevent 32` 
              when "e"
                `#{adb_path} shell input keyevent 33` 
              when "f"
                `#{adb_path} shell input keyevent 34` 
              when "g"
                `#{adb_path} shell input keyevent 35` 
              when "h"
                `#{adb_path} shell input keyevent 36` 
              when "i"
                `#{adb_path} shell input keyevent 37` 
              when "j"
                `#{adb_path} shell input keyevent 38` 
              when "k"
                `#{adb_path} shell input keyevent 39` 
              when "l"
                `#{adb_path} shell input keyevent 40` 
              when "m"
                `#{adb_path} shell input keyevent 41` 
              when "n"
                `#{adb_path} shell input keyevent 42` 
              when "o"
                `#{adb_path} shell input keyevent 43` 
              when "p"
                `#{adb_path} shell input keyevent 44` 
              when "q"
                `#{adb_path} shell input keyevent 45` 
              when "r"
                `#{adb_path} shell input keyevent 46` 
              when "s"
                `#{adb_path} shell input keyevent 47` 
              when "t"
                `#{adb_path} shell input keyevent 48` 
              when "u"
                `#{adb_path} shell input keyevent 49` 
              when "v"
                `#{adb_path} shell input keyevent 50` 
              when "w"
                `#{adb_path} shell input keyevent 51` 
              when "x"
                `#{adb_path} shell input keyevent 52` 
              when "y"
                `#{adb_path} shell input keyevent 53` 
              when "z"
                `#{adb_path} shell input keyevent 54` 
              when ","
                `#{adb_path} shell input keyevent 55` 
              when "."
                `#{adb_path} shell input keyevent 56` 
              when " "
                `#{adb_path} shell input keyevent 62` 
              when '`'
                `#{adb_path} shell input keyevent 68` 
              when "-"
                `#{adb_path} shell input keyevent 69` 
              when "="
                `#{adb_path} shell input keyevent 70` 
              when "["
                `#{adb_path} shell input keyevent 71` 
              when "]"
                `#{adb_path} shell input keyevent 72` 
              when "\\"
                `#{adb_path} shell input keyevent 73` 
              when ";"
                `#{adb_path} shell input keyevent 74` 
              when "'"
                `#{adb_path} shell input keyevent 75` 
              when "/"
                `#{adb_path} shell input keyevent 76` 
              when "@"
                `#{adb_path} shell input keyevent 77` 
              when "#"
                `#{adb_path} shell input keyevent 78` 
              when "+"
                `#{adb_path} shell input keyevent 81` 
            else
              raise "ERROR: unknown char: #{char}"
              return 1
            end
          end
          return 0
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.type_special_string(
      #   :adb_path => 'required - path to adb binary',
      #   :string => 'required - special string to type (:unknown|:menu|:soft_right|:home|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headset_hook|:focus|:menu2|:notification|:search|:tag_last_keycode)'
      # )
      public
      def self.type_special_string(opts={})
        adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        string = opts[:string].to_s.scrub

        begin
          case string
            when :unknown
              `#{adb_path} shell input keyevent 0` 
            when :menu
              `#{adb_path} shell input keyevent 1` 
            when :soft_right
              `#{adb_path} shell input keyevent 2` 
            when :home
              `#{adb_path} shell input keyevent 3` 
            when :back
              `#{adb_path} shell input keyevent 4` 
            when :call
              `#{adb_path} shell input keyevent 5` 
            when :endcall
              `#{adb_path} shell input keyevent 6` 
            when :dpad_up
              `#{adb_path} shell input keyevent 19` 
            when :dpad_down
              `#{adb_path} shell input keyevent 20` 
            when :dpad_left
              `#{adb_path} shell input keyevent 21` 
            when :dpad_right
              `#{adb_path} shell input keyevent 22` 
            when :dpad_center
              `#{adb_path} shell input keyevent 23` 
            when :volume_up
              `#{adb_path} shell input keyevent 24` 
            when :volume_down
              `#{adb_path} shell input keyevent 25` 
            when :power
              `#{adb_path} shell input keyevent 26` 
            when :camera
              `#{adb_path} shell input keyevent 27` 
            when :clear
              `#{adb_path} shell input keyevent 28` 
            when :alt_left
              `#{adb_path} shell input keyevent 57` 
            when :alt_right
              `#{adb_path} shell input keyevent 58` 
            when :shift_left
              `#{adb_path} shell input keyevent 59` 
            when :shift_right
              `#{adb_path} shell input keyevent 60` 
            when :tab
              `#{adb_path} shell input keyevent 61` 
            when :sym
              `#{adb_path} shell input keyevent 63` 
            when :explorer
              `#{adb_path} shell input keyevent 64` 
            when :envelope
              `#{adb_path} shell input keyevent 65` 
            when :enter
              `#{adb_path} shell input keyevent 66` 
            when :del
              `#{adb_path} shell input keyevent 67` 
            when :headset_hook
              `#{adb_path} shell input keyevent 79` 
            when :focus
              `#{adb_path} shell input keyevent 80` 
            when :menu2
              `#{adb_path} shell input keyevent 82` 
            when :notification
              `#{adb_path} shell input keyevent 83` 
            when :search
              `#{adb_path} shell input keyevent 84` 
            when :tag_last_keycode
              `#{adb_path} shell input keyevent 85` 
          else
            raise "ERROR: unknown special string: #{string}"
            return 1
          end
          return 0
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

          installed_apps_arr = #{self}.list_installed_apps(
            :adb_path => 'required - path to adb binary',
            :as_root => 'optional - boolean (defaults to false)',
          )

          app_response = #{self}.open_app(
            :adb_path => 'required - path to adb binary',
            :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
            :as_root => 'optional - boolean (defaults to false)'
          )

          #{self}.type_string(
            :adb_path => 'required - path to adb binary',
            :string => 'required - string to type'
          )

          #{self}.type_special_string(
            :adb_path => 'required - path to adb binary',
            :string => 'required - special string to type (:unknown|:menu|:soft_right|:home|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headset_hook|:focus|:menu2|:notification|:search|:tag_last_keycode)'
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
