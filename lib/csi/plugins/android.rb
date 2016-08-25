require 'yaml'
module CSI
  module Plugins
    # CSI module used to interact w/ Android Devices
    module Android
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_sh(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :command => 'required - adb command to execute'
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_sh(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
          
        command = opts[:command].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          adb_response = `#{$adb_path} shell #{command}` 

          return adb_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_push(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :file => 'required - source file to push',
      #   :dest => 'required - destination path to push file',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_push(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        file = opts[:file].to_s.scrub if File.exists?(opts[:file].to_s.scrub)
        dest = opts[:dest].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          adb_push_response = `#{$adb_path} push #{file} #{dest}` 

          return adb_push_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_pull(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :file => 'required - source file to pull',
      #   :dest => 'required - destination path to pull file',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.adb_pull(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        file = opts[:file].to_s.scrub 
        dest = opts[:dest].to_s.scrub if Dir.exists?(opts[:dest].to_s.scrub)

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          adb_pull = `#{$adb_path} pull #{file} #{dest}` 

          return adb_pull
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.take_screenshot(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :dest => 'required - destination path to save screenshot file',
      #   :as_root => 'optional - boolean (defaults to true)'
      # )
      public
      def self.take_screenshot(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        dest = opts[:dest].to_s.scrub

        if opts[:as_root]
          as_root = false
        else
          as_root = true
        end

        begin
          `#{$adb_path} root` if as_root
          adb_pull = `#{$adb_path} shell screencap -p #{dest}` 

          return adb_pull
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.list_installed_apps(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.list_installed_apps(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          app_resp = `#{$adb_path} shell pm list packages` 
          app_resp_arr = app_resp.gsub("\npackage:" , "\n").split("\r\n")

          return app_resp_arr
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.open_app(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.open_app(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        app = opts[:app].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          app_response = `#{$adb_path} shell monkey -p #{app} -c android.intent.category.LAUNCHER 1` 

          return app_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.type_string(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :string => 'required - string to type'
      # )
      public
      def self.type_string(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        string = opts[:string].to_s.scrub

        begin
          string.each_char do |char|
            case char
              when "0"
                `#{$adb_path} shell input keyevent KEYCODE_0` 
              when "1"
                `#{$adb_path} shell input keyevent KEYCODE_1` 
              when "2"
                `#{$adb_path} shell input keyevent KEYCODE_2` 
              when "3"
                `#{$adb_path} shell input keyevent KEYCODE_3` 
              when "4"
                `#{$adb_path} shell input keyevent KEYCODE_4` 
              when "5"
                `#{$adb_path} shell input keyevent KEYCODE_5` 
              when "6"
                `#{$adb_path} shell input keyevent KEYCODE_6` 
              when "7"
                `#{$adb_path} shell input keyevent KEYCODE_7` 
              when "8"
                `#{$adb_path} shell input keyevent KEYCODE_8` 
              when "9"
                `#{$adb_path} shell input keyevent KEYCODE_9` 
              when "*"
                `#{$adb_path} shell input keyevent KEYCODE_STAR` 
              when "#"
                `#{$adb_path} shell input keyevent KEYCODE_POUND` 
              when "a"
                `#{$adb_path} shell input keyevent KEYCODE_A` 
              when "b"
                `#{$adb_path} shell input keyevent KEYCODE_B` 
              when "c"
                `#{$adb_path} shell input keyevent KEYCODE_C` 
              when "d"
                `#{$adb_path} shell input keyevent KEYCODE_D` 
              when "e"
                `#{$adb_path} shell input keyevent KEYCODE_E` 
              when "f"
                `#{$adb_path} shell input keyevent KEYCODE_F` 
              when "g"
                `#{$adb_path} shell input keyevent KEYCODE_G` 
              when "h"
                `#{$adb_path} shell input keyevent KEYCODE_H` 
              when "i"
                `#{$adb_path} shell input keyevent KEYCODE_I` 
              when "j"
                `#{$adb_path} shell input keyevent KEYCODE_J` 
              when "k"
                `#{$adb_path} shell input keyevent KEYCODE_K` 
              when "l"
                `#{$adb_path} shell input keyevent KEYCODE_L` 
              when "m"
                `#{$adb_path} shell input keyevent KEYCODE_M` 
              when "n"
                `#{$adb_path} shell input keyevent KEYCODE_N` 
              when "o"
                `#{$adb_path} shell input keyevent KEYCODE_O` 
              when "p"
                `#{$adb_path} shell input keyevent KEYCODE_P` 
              when "q"
                `#{$adb_path} shell input keyevent KEYCODE_Q` 
              when "r"
                `#{$adb_path} shell input keyevent KEYCODE_R` 
              when "s"
                `#{$adb_path} shell input keyevent KEYCODE_S` 
              when "t"
                `#{$adb_path} shell input keyevent KEYCODE_T` 
              when "u"
                `#{$adb_path} shell input keyevent KEYCODE_U` 
              when "v"
                `#{$adb_path} shell input keyevent KEYCODE_V` 
              when "w"
                `#{$adb_path} shell input keyevent KEYCODE_W` 
              when "x"
                `#{$adb_path} shell input keyevent KEYCODE_X` 
              when "y"
                `#{$adb_path} shell input keyevent KEYCODE_Y` 
              when "z"
                `#{$adb_path} shell input keyevent KEYCODE_Z` 
              when ","
                `#{$adb_path} shell input keyevent KEYCODE_COMMA` 
              when "."
                `#{$adb_path} shell input keyevent KEYCODE_PERIOD` 
              when " "
                `#{$adb_path} shell input keyevent KEYCODE_SPACE` 
              when '`'
                `#{$adb_path} shell input keyevent KEYCODE_GRAVE` 
              when "-"
                `#{$adb_path} shell input keyevent KEYCODE_MINUS` 
              when "="
                `#{$adb_path} shell input keyevent KEYCODE_EQUALS` 
              when "["
                `#{$adb_path} shell input keyevent KEYCODE_LEFT_BRACKET` 
              when "]"
                `#{$adb_path} shell input keyevent KEYCODE_RIGHT_BRACKET` 
              when "\\"
                `#{$adb_path} shell input keyevent KEYCODE_BACKSLASH` 
              when ";"
                `#{$adb_path} shell input keyevent KEYCODE_SEMICOLON` 
              when "'"
                `#{$adb_path} shell input keyevent KEYCODE_APOSTROPHE` 
              when "/"
                `#{$adb_path} shell input keyevent KEYCODE_SLASH` 
              when "@"
                `#{$adb_path} shell input keyevent KEYCODE_AT` 
              when "+"
                `#{$adb_path} shell input keyevent KEYCODE_PLUS` 
              when "("
                `#{$adb_path} shell input keyevent KEYCODE_LEFT_PAREN` 
              when ")"
                `#{$adb_path} shell input keyevent KEYCODE_RIGHT_PAREN` 
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
      # CSI::Plugins::AndroidADB.type_special_key(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :string => 'required - special string to type (:zoom_in|:zoom_out|:zenkaku_hankaku|:yen|:window|:wakeup|:voice_assist|:tv_zoom_mode|:tv_timer_programming|:tv_terrestrial_digital|:tv_terrestrial_analog|:tv_satellite_teletext|:tv_satellite_service|:tv_satellite|:tv_satellite_bs|:tv_satellite_cs|:tv_radio_service|:tv_power|:tv_number_entry|:tv_network|:tv_media_context_menu|:tv_input_vga_1|:tv_input_hdmi_1|:tv_input_hdmi_2|:tv_input_hdmi_3|:tv_input_hdmi_4|:tv_input_composite_1|:tv_input_composite_2|:tv_input_component_1|:tv_input_component_2|:tv_input|:tv_data_service|:tv_contents_menu|:tv_audio_desc|:tv_audio_desc_mix_up|:tv_audio_desc_mix_down|:tv_antenna_cable|:tv|:sysrq|:switch_charset|:stem_primary|:stem1|:stem2|:stem3|:stb_power|:stb_input|:sleep|:settings|:scroll_lock, :ro, :prog_blue|:prog_green|:prog_red|:prog_yellow|:pairing|:num_lock|:numpad_subtract|:numpad_multiply|:numpad_left_paren|:numpad_right_paren|:numpad_equals|:numpad_enter|:numpad_dot|:numpad_comma|:numpad_add|:numpad0|:numpad1|:numpad2|:numpad3|:numpad4|:numpad5|:numpad6|:numpad7|:numpad8|:numpad9|:num|:nav_in|:nav_next|:nav_out|:nav_previous|:music|:muhenkan|:meta_left|:meta_right|:media_top_menu|:media_step_forward|:media_step_back|:media_skip_forward|:media_skip_back|:media_record|:media_play|:media_eject|:media_close|:media_audio_track|:manner_mode|:last_channel|:language_switch|:katakana_hiragana|:kana|:insert|:info|:henkan|:help|:guide|:forward_del|:f1|:f2|:f3|:f4|:f5|:f6|:f7|:f8|:f9|:f10|:f11|:f12|:escape|:eisu|:dvr|:ctrl_left|:ctrl_right|:cut|:copy|:paste|:contacts|:chan_down|:chan_up|:captions|:caps_lock|:calendar|:calculator|:gamepad_1|:gamepad_2|:gamepad_3|:gamepad_4|:gamepad_5|:gamepad_6|:gamepad_7|:gamepad_8|:gamepad_9|:gamepad_10|:gamepad_11|:gamepad_12|:gamepad_13|:gamepad_14|:gamepad_15|:gamepad_16|:gamepad_a|:gamepad_b|:gamepad_c|:gamepad_l1|:gamepad_l2|:gamepad_mode|:gamepad_r1|:gamepad_r2|:gamepad_select|:gamepad_start|:gamepad_thumbl|:gamepad_thumbr|:gamepad_x|:gamepad_y|:gamepad_z|:brightness_up|:brightness_down|:break|:bookmark|:avr_power|:avr_input|:assist|:app_switch|:threeDmode|:eleven|:twelve|:unknown|:soft_left|:soft_right|:soft_sleep|:home|:forward|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_down_left|:dpad_down_right|:dpad_up_left|:dpad_up_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headsethook|:focus|:menu|:notification|:search|:media_play_pause|:media_stop|:media_next|:media_previous|:media_rewind|:media_fast_forward|:mute|:page_up|:page_down|:pictsymbols|:move_home|:move_end) see https://developer.android.com/reference/android/view/KeyEvent.html for more info'
      # )
      public
      def self.type_special_key(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        string = opts[:string].to_s.scrub.to_sym

        begin
          case string
            when :zoom_in
              `#{$adb_path} shell input keyevent KEYCODE_ZOOM_IN` 
            when :zoom_out
              `#{$adb_path} shell input keyevent KEYCODE_ZOOM_OUT` 
            when :zenkaku_hankaku
              `#{$adb_path} shell input keyevent KEYCODE_ZENKAKU_HANKAKU` 
            when :yen
              `#{$adb_path} shell input keyevent KEYCODE_YEN` 
            when :window
              `#{$adb_path} shell input keyevent KEYCODE_WINDOW` 
            when :wakeup
              `#{$adb_path} shell input keyevent KEYCODE_WAKEUP` 
            when :voice_assist
              `#{$adb_path} shell input keyevent KEYCODE_VOICE_ASSIST` 
            when :tv_zoom_mode
              `#{$adb_path} shell input keyevent KEYCODE_TV_ZOOM_MODE` 
            when :tv_timer_programming
              `#{$adb_path} shell input keyevent KEYCODE_TV_TIMER_PROGRAMMING` 
            when :tv_terrestrial_digital
              `#{$adb_path} shell input keyevent KEYCODE_TV_TERRESTRIAL_DIGITAL` 
            when :tv_terrestrial_analog
              `#{$adb_path} shell input keyevent KEYCODE_TV_TERRESTRIAL_ANALOG` 
            when :tv_satellite_teletext
              `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_TELETEXT` 
            when :tv_satellite_service
              `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_SERVICE` 
            when :tv_satellite_bs
              `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_BS` 
            when :tv_satellite_cs
              `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_CS` 
            when :tv_satellite
              `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE` 
            when :tv_radio_service
              `#{$adb_path} shell input keyevent KEYCODE_TV_RADIO_SERVICE` 
            when :tv_power
              `#{$adb_path} shell input keyevent KEYCODE_TV_POWER` 
            when :tv_number_entry
              `#{$adb_path} shell input keyevent KEYCODE_TV_NUMBER_ENTRY` 
            when :tv_network
              `#{$adb_path} shell input keyevent KEYCODE_TV_NETWORK` 
            when :tv_media_context_menu
              `#{$adb_path} shell input keyevent KEYCODE_TV_MEDIA_CONTEXT_MENU` 
            when :tv_input_vga_1
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_VGA_1` 
            when :tv_input_hdmi_1
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_1` 
            when :tv_input_hdmi_2
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_2` 
            when :tv_input_hdmi_3
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_3` 
            when :tv_input_hdmi_4
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_4` 
            when :tv_input_composite_1
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPOSITE_1` 
            when :tv_input_composite_2
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPOSITE_2` 
            when :tv_input_component_1
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPONENT_1` 
            when :tv_input_component_2
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPONENT_2` 
            when :tv_input
              `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT` 
            when :tv_data_service
              `#{$adb_path} shell input keyevent KEYCODE_TV_DATA_SERVICE` 
            when :tv_contents_menu
              `#{$adb_path} shell input keyevent KEYCODE_TV_CONTENTS_MENU` 
            when :tv_audio_desc
              `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION` 
            when :tv_audio_desc_mix_up
              `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION_MIX_UP` 
            when :tv_audio_desc_mix_down
              `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION_MIX_DOWN` 
            when :tv_antenna_cable
              `#{$adb_path} shell input keyevent KEYCODE_TV_ANTENNA_CABLE` 
            when :tv
              `#{$adb_path} shell input keyevent KEYCODE_TV` 
            when :sysrq
              `#{$adb_path} shell input keyevent KEYCODE_SYSRQ` 
            when :switch_charset
              `#{$adb_path} shell input keyevent KEYCODE_SWITCH_CHARSET` 
            when :stem_primary
              `#{$adb_path} shell input keyevent KEYCODE_STEM_PRIMARY` 
            when :stem1
              `#{$adb_path} shell input keyevent KEYCODE_STEM_1` 
            when :stem2
              `#{$adb_path} shell input keyevent KEYCODE_STEM_2` 
            when :stem3
              `#{$adb_path} shell input keyevent KEYCODE_STEM_3` 
            when :stb_power
              `#{$adb_path} shell input keyevent KEYCODE_STB_POWER` 
            when :stb_input
              `#{$adb_path} shell input keyevent KEYCODE_STB_INPUT` 
            when :sleep
              `#{$adb_path} shell input keyevent KEYCODE_SLEEP` 
            when :settings
              `#{$adb_path} shell input keyevent KEYCODE_SETTINGS` 
            when :scroll_lock
              `#{$adb_path} shell input keyevent KEYCODE_SCROLL_LOCK` 
            when :ro
              `#{$adb_path} shell input keyevent KEYCODE_RO` 
            when :prog_blue
              `#{$adb_path} shell input keyevent KEYCODE_PROG_BLUE` 
            when :prog_green
              `#{$adb_path} shell input keyevent KEYCODE_PROG_GREEN` 
            when :prog_red
              `#{$adb_path} shell input keyevent KEYCODE_PROG_RED` 
            when :prog_yellow
              `#{$adb_path} shell input keyevent KEYCODE_PROG_YELLOW` 
            when :pairing
              `#{$adb_path} shell input keyevent KEYCODE_PARING` 
            when :num_lock
              `#{$adb_path} shell input keyevent KEYCODE_NUM_LOCK` 
            when :numpad_subtract
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_SUBTRACT` 
            when :numpad_multiply
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_MULTIPLY` 
            when :numpad_left_paren
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_LEFT_PAREN` 
            when :numpad_right_paren
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_RIGHT_PAREN` 
            when :numpad_equals
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_EQUALS` 
            when :numpad_enter
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_ENTER` 
            when :numpad_dot
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_DOT` 
            when :numpad_divide
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_DIVIDE` 
            when :numpad_comma
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_COMMA` 
            when :numpad_add
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_ADD` 
            when :numpad0
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_0` 
            when :numpad1
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_1` 
            when :numpad2
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_2` 
            when :numpad3
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_3` 
            when :numpad4
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_4` 
            when :numpad5
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_5` 
            when :numpad6
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_6` 
            when :numpad7
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_7` 
            when :numpad8
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_8` 
            when :numpad9
              `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_9` 
            when :num
              `#{$adb_path} shell input keyevent KEYCODE_NUM` 
            when :nav_in
              `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_IN` 
            when :nav_next
              `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_NEXT` 
            when :nav_out
              `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_OUT` 
            when :nav_previous
              `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_PREVIOUS` 
            when :music
              `#{$adb_path} shell input keyevent KEYCODE_MUSIC` 
            when :muhenkan
              `#{$adb_path} shell input keyevent KEYCODE_MUHENKAN` 
            when :meta_left
              `#{$adb_path} shell input keyevent KEYCODE_META_LEFT` 
            when :meta_right
              `#{$adb_path} shell input keyevent KEYCODE_META_RIGHT` 
            when :media_top_menu
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_TOP_MENU` 
            when :media_step_forward
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STEP_FORWARD` 
            when :media_step_back
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STEP_BACKWARD` 
            when :media_skip_forward
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_SKIP_FORWARD` 
            when :media_skip_back
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_SKIP_BACKWARD` 
            when :media_record
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_RECORD` 
            when :media_play
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PLAY` 
            when :media_pause
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PAUSE` 
            when :media_eject
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_EJECT` 
            when :media_close
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_CLOSE` 
            when :media_audio_track
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_AUDIO_TRACK` 
            when :manner_mode
              `#{$adb_path} shell input keyevent KEYCODE_MANNER_MODE` 
            when :last_channel
              `#{$adb_path} shell input keyevent KEYCODE_LAST_CHANNEL` 
            when :language_switch
              `#{$adb_path} shell input keyevent KEYCODE_LANGUAGE_SWITCH` 
            when :katakana_hiragana
              `#{$adb_path} shell input keyevent KEYCODE_KATAKANA_HIRAGANA` 
            when :kana
              `#{$adb_path} shell input keyevent KEYCODE_KANA` 
            when :insert
              `#{$adb_path} shell input keyevent KEYCODE_INSERT` 
            when :info
              `#{$adb_path} shell input keyevent KEYCODE_INFO` 
            when :henkan
              `#{$adb_path} shell input keyevent KEYCODE_HENKAN` 
            when :help
              `#{$adb_path} shell input keyevent KEYCODE_HELP` 
            when :guide
              `#{$adb_path} shell input keyevent KEYCODE_GUIDE` 
            when :function
              `#{$adb_path} shell input keyevent KEYCODE_FUNCTION` 
            when :forward_del
              `#{$adb_path} shell input keyevent KEYCODE_FORWARD_DEL` 
            when :f1
              `#{$adb_path} shell input keyevent KEYCODE_F1` 
            when :f2
              `#{$adb_path} shell input keyevent KEYCODE_F2` 
            when :f3
              `#{$adb_path} shell input keyevent KEYCODE_F3` 
            when :f4
              `#{$adb_path} shell input keyevent KEYCODE_F4` 
            when :f5
              `#{$adb_path} shell input keyevent KEYCODE_F5` 
            when :f6
              `#{$adb_path} shell input keyevent KEYCODE_F6` 
            when :f7
              `#{$adb_path} shell input keyevent KEYCODE_F7` 
            when :f8
              `#{$adb_path} shell input keyevent KEYCODE_F8` 
            when :f9
              `#{$adb_path} shell input keyevent KEYCODE_F9` 
            when :f10
              `#{$adb_path} shell input keyevent KEYCODE_F10` 
            when :f11
              `#{$adb_path} shell input keyevent KEYCODE_F11` 
            when :f12
              `#{$adb_path} shell input keyevent KEYCODE_F12` 
            when :escape
              `#{$adb_path} shell input keyevent KEYCODE_ESCAPE` 
            when :eisu
              `#{$adb_path} shell input keyevent KEYCODE_EISU` 
            when :dvr
              `#{$adb_path} shell input keyevent KEYCODE_DVR` 
            when :ctrl_left
              `#{$adb_path} shell input keyevent KEYCODE_CTRL_LEFT` 
            when :ctrl_right
              `#{$adb_path} shell input keyevent KEYCODE_CTRL_RIGHT` 
            when :cut
              `#{$adb_path} shell input keyevent KEYCODE_CUT` 
            when :copy
              `#{$adb_path} shell input keyevent KEYCODE_COPY` 
            when :paste
              `#{$adb_path} shell input keyevent KEYCODE_PASTE` 
            when :contacts
              `#{$adb_path} shell input keyevent KEYCODE_CONTACTS` 
            when :chan_down
              `#{$adb_path} shell input keyevent KEYCODE_CHANNEL_DOWN` 
            when :chan_up
              `#{$adb_path} shell input keyevent KEYCODE_CHANNEL_UP` 
            when :captions
              `#{$adb_path} shell input keyevent KEYCODE_CAPTIONS` 
            when :caps_lock
              `#{$adb_path} shell input keyevent KEYCODE_CAPS_LOCK` 
            when :calendar
              `#{$adb_path} shell input keyevent KEYCODE_CALENDAR` 
            when :calculator
              `#{$adb_path} shell input keyevent KEYCODE_CALCULATOR` 
            when :gamepad_1
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_1` 
            when :gamepad_2
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_2` 
            when :gamepad_3
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_3` 
            when :gamepad_4
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_4` 
            when :gamepad_5
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_5` 
            when :gamepad_6
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_6` 
            when :gamepad_7
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_7` 
            when :gamepad_8
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_8` 
            when :gamepad_9
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_9` 
            when :gamepad_10
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_10` 
            when :gamepad_11
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_11` 
            when :gamepad_12
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_12` 
            when :gamepad_13
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_13` 
            when :gamepad_14
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_14` 
            when :gamepad_15
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_15` 
            when :gamepad_16
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_16` 
            when :gamepad_16
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_16` 
            when :gamepad_a
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_A` 
            when :gamepad_b
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_B` 
            when :gamepad_c
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_C` 
            when :gamepad_l1
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_L1` 
            when :gamepad_l2
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_L2` 
            when :gamepad_mode
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_MODE` 
            when :gamepad_r1
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_R1` 
            when :gamepad_r2
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_R2` 
            when :gamepad_select
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_SELECT` 
            when :gamepad_start
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_START` 
            when :gamepad_thumbl
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_THUMBL` 
            when :gamepad_thumbr
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_THUMBR` 
            when :gamepad_x
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_X` 
            when :gamepad_y
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_Y` 
            when :gamepad_z
              `#{$adb_path} shell input keyevent KEYCODE_BUTTON_Z` 
            when :brightness_up
              `#{$adb_path} shell input keyevent KEYCODE_BRIGHTNESS_UP` 
            when :brightness_down
              `#{$adb_path} shell input keyevent KEYCODE_BRIGHTNESS_DOWN` 
            when :break
              `#{$adb_path} shell input keyevent KEYCODE_BREAK` 
            when :bookmark
              `#{$adb_path} shell input keyevent KEYCODE_BOOKMARK` 
            when :avr_power
              `#{$adb_path} shell input keyevent KEYCODE_AVR_POWER` 
            when :avr_input
              `#{$adb_path} shell input keyevent KEYCODE_AVR_INPUT` 
            when :assist
              `#{$adb_path} shell input keyevent KEYCODE_ASSIST` 
            when :app_switch
              `#{$adb_path} shell input keyevent KEYCODE_APP_SWITCH` 
            when :threeDmode
              `#{$adb_path} shell input keyevent KEYCODE_3D_MODE` 
            when :eleven
              `#{$adb_path} shell input keyevent KEYCODE_11` 
            when :twelve
              `#{$adb_path} shell input keyevent KEYCODE_12` 
            when :unknown
              `#{$adb_path} shell input keyevent KEYCODE_UNKNOWN` 
            when :soft_left
              `#{$adb_path} shell input keyevent KEYCODE_SOFT_LEFT` 
            when :soft_right
              `#{$adb_path} shell input keyevent KEYCODE_SOFT_RIGHT` 
            when :soft_sleep
              `#{$adb_path} shell input keyevent KEYCODE_SOFT_SLEEP` 
            when :home
              `#{$adb_path} shell input keyevent KEYCODE_HOME` 
            when :forward
              `#{$adb_path} shell input keyevent KEYCODE_FORWARD` 
            when :back
              `#{$adb_path} shell input keyevent KEYCODE_BACK` 
            when :call
              `#{$adb_path} shell input keyevent KEYCODE_CALL` 
            when :endcall
              `#{$adb_path} shell input keyevent KEYCODE_ENDCALL` 
            when :dpad_up
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP` 
            when :dpad_down
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN` 
            when :dpad_left
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_LEFT` 
            when :dpad_right
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_RIGHT` 
            when :dpad_down_left
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN_LEFT` 
            when :dpad_down_right
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN_RIGHT` 
            when :dpad_up_left
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP_LEFT` 
            when :dpad_up_right
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP_RIGHT` 
            when :dpad_center
              `#{$adb_path} shell input keyevent KEYCODE_DPAD_CENTER` 
            when :volume_up
              `#{$adb_path} shell input keyevent KEYCODE_VOLUME_UP` 
            when :volume_down
              `#{$adb_path} shell input keyevent KEYCODE_VOLUME_DOWN` 
            when :power
              `#{$adb_path} shell input keyevent KEYCODE_POWER` 
            when :camera
              `#{$adb_path} shell input keyevent KEYCODE_CAMERA` 
            when :clear
              `#{$adb_path} shell input keyevent KEYCODE_CLEAR` 
            when :alt_left
              `#{$adb_path} shell input keyevent KEYCODE_ALT_LEFT` 
            when :alt_right
              `#{$adb_path} shell input keyevent KEYCODE_ALT_RIGHT` 
            when :shift_left
              `#{$adb_path} shell input keyevent KEYCODE_SHIFT_LEFT` 
            when :shift_right
              `#{$adb_path} shell input keyevent KEYCODE_SHIFT_RIGHT` 
            when :tab
              `#{$adb_path} shell input keyevent KEYCODE_TAB` 
            when :sym
              `#{$adb_path} shell input keyevent KEYCODE_SYM` 
            when :explorer
              `#{$adb_path} shell input keyevent KEYCODE_EXPLORER` 
            when :envelope
              `#{$adb_path} shell input keyevent KEYCODE_ENVELOPE` 
            when :enter
              `#{$adb_path} shell input keyevent KEYCODE_ENTER` 
            when :del
              `#{$adb_path} shell input keyevent KEYCODE_DEL` 
            when :headsethook
              `#{$adb_path} shell input keyevent KEYCODE_HEADSETHOOK` 
            when :focus
              `#{$adb_path} shell input keyevent KEYCODE_FOCUS` 
            when :menu
              `#{$adb_path} shell input keyevent KEYCODE_MENU` 
            when :notification
              `#{$adb_path} shell input keyevent KEYCODE_NOTIFICATION` 
            when :search
              `#{$adb_path} shell input keyevent KEYCODE_SEARCH` 
            when :media_play_pause
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PLAY_PAUSE` 
            when :media_stop
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STOP` 
            when :media_next
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_NEXT` 
            when :media_previous
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PREVIOUS` 
            when :media_rewind
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_REWIND` 
            when :media_fast_forward
              `#{$adb_path} shell input keyevent KEYCODE_MEDIA_FAST_FORWARD` 
            when :mute
              `#{$adb_path} shell input keyevent KEYCODE_MUTE` 
            when :page_up
              `#{$adb_path} shell input keyevent KEYCODE_PAGE_UP` 
            when :page_down
              `#{$adb_path} shell input keyevent KEYCODE_PAGE_DOWN` 
            when :pictsymbols
              `#{$adb_path} shell input keyevent KEYCODE_PICTSYMBOLS` 
            when :move_home
              `#{$adb_path} shell input keyevent KEYCODE_MOVE_HOME` 
            when :move_end
              `#{$adb_path} shell input keyevent KEYCODE_MOVE_END` 
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
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :app => 'required - application app to close (i.e. open an android app returned from #list_install_apps method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.close_app(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        app = opts[:app].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          app_response = `#{$adb_path} shell am force-stop #{app}` 

          return app_response
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.invoke_event_listener(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :as_root => 'optional - boolean (defaults to false)',
      # )
      public
      def self.invoke_event_listener(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        app = opts[:app].to_s.scrub

        if opts[:as_root]
          as_root = true
        else
          as_root = false
        end

        begin
          `#{$adb_path} root` if as_root
          `#{$adb_path} shell get event -l` 
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
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :command => 'adb command to execute'
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.adb_push(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :file => 'required - source file to push',
            :dest => 'required - destination path to push file',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.adb_pull(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :file => 'required - source file to pull',
            :dest => 'required - destination path to pull file',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.take_screenshot(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :dest => 'required - destination path to save screenshot file',
            :as_root => 'optional - boolean (defaults to true)'
          )

          installed_apps_arr = #{self}.list_installed_apps(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :as_root => 'optional - boolean (defaults to false)',
          )

          app_response = #{self}.open_app(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
            :as_root => 'optional - boolean (defaults to false)'
          )

          #{self}.type_string(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :string => 'required - string to type'
          )

          #{self}.type_special_key(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :string => 'required - special string to type (:unknown|:menu|:soft_right|:home|:forward|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headsethook|:focus|:menu2|:notification|:search|:tag_last_keycode)'
          )

          app_response = #{self}.close_app(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :app => 'required - application app to run (i.e. open an android app returned from #list_install_apps method)',
            :as_root => 'optional - boolean (defaults to false)'
          )

          #{self}.invoke_event_listener(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :as_root => 'optional - boolean (defaults to false)',
          )

          #{self}.authors
        }
      end
    end
  end
end
