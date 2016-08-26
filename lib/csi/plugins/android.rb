require 'yaml'
module CSI
  module Plugins
    # CSI module used to interact w/ Android Devices
    module Android
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_net_connect(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :target => 'required - target host or IP to connect',
      #   :port => 'optional - defaults to tcp 5555'
      # )
      public
      def self.adb_net_connect(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        target = opts[:target].to_s.scrub
        if opts[:port]
          port = opts[:port].to_i
        else
          port = 5555
        end

        begin
          adb_response = `#{$adb_path} connect #{target}:#{port}` 

          return adb_response
        rescue => e
          return e.message
        end
      end

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
      # CSI::Plugins::AndroidADB.find_hidden_codes(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :from => 'required - start at keycode #'
      #   :to => 'required - end at keycode #'
      # )
      public
      def self.find_hidden_codes(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        from = opts[:from].to_i
        to = opts[:to].to_i

        begin
          (from..to).each do |n| 
	    puts `#{$adb_path} shell input keyevent #{n}` 
            gets
          end
          return
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.input(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :string => 'required - string to type'
      # )
      public
      def self.input(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        string = opts[:string].to_s.scrub

        begin
          char_resp = ""
          string.each_char do |char|
            case char
              when "0"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_0` 
              when "1"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_1` 
              when "2"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_2` 
              when "3"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_3` 
              when "4"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_4` 
              when "5"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_5` 
              when "6"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_6` 
              when "7"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_7` 
              when "8"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_8` 
              when "9"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_9` 
              when "*"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_STAR` 
              when "#"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_POUND` 
              when "a"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_A` 
              when "b"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_B` 
              when "c"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_C` 
              when "d"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_D` 
              when "e"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_E` 
              when "f"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_F` 
              when "g"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_G` 
              when "h"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_H` 
              when "i"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_I` 
              when "j"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_J` 
              when "k"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_K` 
              when "l"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_L` 
              when "m"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_M` 
              when "n"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_N` 
              when "o"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_P` 
              when "q"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_Q` 
              when "r"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_R` 
              when "s"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_S` 
              when "t"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_T` 
              when "u"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_U` 
              when "v"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_V` 
              when "w"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_W` 
              when "x"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_X` 
              when "y"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_Y` 
              when "z"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_Z` 
              when ","
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_COMMA` 
              when "."
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_PERIOD` 
              when " "
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_SPACE` 
              when '`'
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_GRAVE` 
              when "-"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_MINUS` 
              when "="
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_EQUALS` 
              when "["
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_LEFT_BRACKET` 
              when "]"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_RIGHT_BRACKET` 
              when "\\"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_BACKSLASH` 
              when ";"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_SEMICOLON` 
              when "'"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_APOSTROPHE` 
              when "/"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_SLASH` 
              when "@"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_AT` 
              when "+"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_PLUS` 
              when "("
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_LEFT_PAREN` 
              when ")"
                char_resp << `#{$adb_path} shell input keyevent KEYCODE_RIGHT_PAREN` 
            else
              raise "ERROR: unknown char: #{char}"
            end
          end

          return char_resp.to_s.scrub
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.input_special(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :keycode => 'required - special keycode to type (:zoom_in|:zoom_out|:zenkaku_hankaku|:yen|:window|:wakeup|:voice_assist|:tv_zoom_mode|:tv_timer_programming|:tv_terrestrial_digital|:tv_terrestrial_analog|:tv_satellite_teletext|:tv_satellite_service|:tv_satellite|:tv_satellite_bs|:tv_satellite_cs|:tv_radio_service|:tv_power|:tv_number_entry|:tv_network|:tv_media_context_menu|:tv_input_vga_1|:tv_input_hdmi_1|:tv_input_hdmi_2|:tv_input_hdmi_3|:tv_input_hdmi_4|:tv_input_composite_1|:tv_input_composite_2|:tv_input_component_1|:tv_input_component_2|:tv_input|:tv_data_service|:tv_contents_menu|:tv_audio_desc|:tv_audio_desc_mix_up|:tv_audio_desc_mix_down|:tv_antenna_cable|:tv|:sysrq|:switch_charset|:stem_primary|:stem1|:stem2|:stem3|:stb_power|:stb_input|:sleep|:settings|:scroll_lock|:ro|:prog_blue|:prog_green|:prog_red|:prog_yellow|:pairing|:num_lock|:numpad_subtract|:numpad_multiply|:numpad_left_paren|:numpad_right_paren|:numpad_equals|:numpad_enter|:numpad_dot|:numpad_comma|:numpad_add|:numpad0|:numpad1|:numpad2|:numpad3|:numpad4|:numpad5|:numpad6|:numpad7|:numpad8|:numpad9|:num|:nav_in|:nav_next|:nav_out|:nav_previous|:music|:muhenkan|:meta_left|:meta_right|:media_top_menu|:media_step_forward|:media_step_back|:media_skip_forward|:media_skip_back|:media_record|:media_play|:media_eject|:media_close|:media_audio_track|:manner_mode|:last_channel|:language_switch|:katakana_hiragana|:kana|:insert|:info|:henkan|:help|:guide|:forward_del|:f1|:f2|:f3|:f4|:f5|:f6|:f7|:f8|:f9|:f10|:f11|:f12|:escape|:eisu|:dvr|:ctrl_left|:ctrl_right|:cut|:copy|:paste|:contacts|:chan_down|:chan_up|:captions|:caps_lock|:calendar|:calculator|:gamepad_1|:gamepad_2|:gamepad_3|:gamepad_4|:gamepad_5|:gamepad_6|:gamepad_7|:gamepad_8|:gamepad_9|:gamepad_10|:gamepad_11|:gamepad_12|:gamepad_13|:gamepad_14|:gamepad_15|:gamepad_16|:gamepad_a|:gamepad_b|:gamepad_c|:gamepad_l1|:gamepad_l2|:gamepad_mode|:gamepad_r1|:gamepad_r2|:gamepad_select|:gamepad_start|:gamepad_thumbl|:gamepad_thumbr|:gamepad_x|:gamepad_y|:gamepad_z|:brightness_up|:brightness_down|:break|:bookmark|:avr_power|:avr_input|:assist|:app_switch|:threeDmode|:eleven|:twelve|:unknown|:soft_left|:soft_right|:soft_sleep|:home|:forward|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_down_left|:dpad_down_right|:dpad_up_left|:dpad_up_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headsethook|:focus|:menu|:notification|:search|:media_play_pause|:media_stop|:media_next|:media_previous|:media_rewind|:media_fast_forward|:mute|:page_up|:page_down|:pictsymbols|:move_home|:move_end) see https://developer.android.com/reference/android/view/KeyEvent.html for more info'
      # )
      public
      def self.input_special(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        keycode = opts[:keycode].to_s.scrub.to_sym

        begin
          str_resp = ""
          case keycode
            when :zoom_in
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ZOOM_IN` 
            when :zoom_out
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ZOOM_OUT` 
            when :zenkaku_hankaku
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ZENKAKU_HANKAKU` 
            when :yen
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_YEN` 
            when :window
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_WINDOW` 
            when :wakeup
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_WAKEUP` 
            when :voice_assist
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_VOICE_ASSIST` 
            when :tv_zoom_mode
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_ZOOM_MODE` 
            when :tv_timer_programming
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_TIMER_PROGRAMMING` 
            when :tv_terrestrial_digital
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_TERRESTRIAL_DIGITAL` 
            when :tv_terrestrial_analog
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_TERRESTRIAL_ANALOG` 
            when :tv_satellite_teletext
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_TELETEXT` 
            when :tv_satellite_service
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_SERVICE` 
            when :tv_satellite_bs
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_BS` 
            when :tv_satellite_cs
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE_CS` 
            when :tv_satellite
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_SATELLITE` 
            when :tv_radio_service
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_RADIO_SERVICE` 
            when :tv_power
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_POWER` 
            when :tv_number_entry
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_NUMBER_ENTRY` 
            when :tv_network
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_NETWORK` 
            when :tv_media_context_menu
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_MEDIA_CONTEXT_MENU` 
            when :tv_input_vga_1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_VGA_1` 
            when :tv_input_hdmi_1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_1` 
            when :tv_input_hdmi_2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_2` 
            when :tv_input_hdmi_3
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_3` 
            when :tv_input_hdmi_4
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_HDMI_4` 
            when :tv_input_composite_1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPOSITE_1` 
            when :tv_input_composite_2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPOSITE_2` 
            when :tv_input_component_1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPONENT_1` 
            when :tv_input_component_2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT_COMPONENT_2` 
            when :tv_input
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_INPUT` 
            when :tv_data_service
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_DATA_SERVICE` 
            when :tv_contents_menu
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_CONTENTS_MENU` 
            when :tv_audio_desc
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION` 
            when :tv_audio_desc_mix_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION_MIX_UP` 
            when :tv_audio_desc_mix_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_AUDIO_DESCRIPTION_MIX_DOWN` 
            when :tv_antenna_cable
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV_ANTENNA_CABLE` 
            when :tv
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TV` 
            when :sysrq
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SYSRQ` 
            when :switch_charset
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SWITCH_CHARSET` 
            when :stem_primary
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STEM_PRIMARY` 
            when :stem1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STEM_1` 
            when :stem2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STEM_2` 
            when :stem3
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STEM_3` 
            when :stb_power
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STB_POWER` 
            when :stb_input
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_STB_INPUT` 
            when :sleep
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SLEEP` 
            when :settings
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SETTINGS` 
            when :scroll_lock
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SCROLL_LOCK` 
            when :ro
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_RO` 
            when :prog_blue
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PROG_BLUE` 
            when :prog_green
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PROG_GREEN` 
            when :prog_red
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PROG_RED` 
            when :prog_yellow
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PROG_YELLOW` 
            when :pairing
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PARING` 
            when :num_lock
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUM_LOCK` 
            when :numpad_subtract
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_SUBTRACT` 
            when :numpad_multiply
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_MULTIPLY` 
            when :numpad_left_paren
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_LEFT_PAREN` 
            when :numpad_right_paren
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_RIGHT_PAREN` 
            when :numpad_equals
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_EQUALS` 
            when :numpad_enter
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_ENTER` 
            when :numpad_dot
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_DOT` 
            when :numpad_divide
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_DIVIDE` 
            when :numpad_comma
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_COMMA` 
            when :numpad_add
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_ADD` 
            when :numpad0
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_0` 
            when :numpad1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_1` 
            when :numpad2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_2` 
            when :numpad3
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_3` 
            when :numpad4
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_4` 
            when :numpad5
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_5` 
            when :numpad6
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_6` 
            when :numpad7
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_7` 
            when :numpad8
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_8` 
            when :numpad9
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUMPAD_9` 
            when :num
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NUM` 
            when :nav_in
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_IN` 
            when :nav_next
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_NEXT` 
            when :nav_out
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_OUT` 
            when :nav_previous
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NAVIGATE_PREVIOUS` 
            when :music
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MUSIC` 
            when :muhenkan
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MUHENKAN` 
            when :meta_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_META_LEFT` 
            when :meta_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_META_RIGHT` 
            when :media_top_menu
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_TOP_MENU` 
            when :media_step_forward
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STEP_FORWARD` 
            when :media_step_back
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STEP_BACKWARD` 
            when :media_skip_forward
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_SKIP_FORWARD` 
            when :media_skip_back
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_SKIP_BACKWARD` 
            when :media_record
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_RECORD` 
            when :media_play
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PLAY` 
            when :media_pause
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PAUSE` 
            when :media_eject
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_EJECT` 
            when :media_close
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_CLOSE` 
            when :media_audio_track
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_AUDIO_TRACK` 
            when :manner_mode
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MANNER_MODE` 
            when :last_channel
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_LAST_CHANNEL` 
            when :language_switch
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_LANGUAGE_SWITCH` 
            when :katakana_hiragana
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_KATAKANA_HIRAGANA` 
            when :kana
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_KANA` 
            when :insert
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_INSERT` 
            when :info
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_INFO` 
            when :henkan
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_HENKAN` 
            when :help
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_HELP` 
            when :guide
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_GUIDE` 
            when :function
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_FUNCTION` 
            when :forward_del
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_FORWARD_DEL` 
            when :f1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F1` 
            when :f2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F2` 
            when :f3
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F3` 
            when :f4
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F4` 
            when :f5
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F5` 
            when :f6
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F6` 
            when :f7
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F7` 
            when :f8
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F8` 
            when :f9
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F9` 
            when :f10
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F10` 
            when :f11
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F11` 
            when :f12
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_F12` 
            when :escape
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ESCAPE` 
            when :eisu
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_EISU` 
            when :dvr
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DVR` 
            when :ctrl_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CTRL_LEFT` 
            when :ctrl_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CTRL_RIGHT` 
            when :cut
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CUT` 
            when :copy
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_COPY` 
            when :paste
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PASTE` 
            when :contacts
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CONTACTS` 
            when :chan_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CHANNEL_DOWN` 
            when :chan_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CHANNEL_UP` 
            when :captions
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CAPTIONS` 
            when :caps_lock
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CAPS_LOCK` 
            when :calendar
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CALENDAR` 
            when :calculator
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CALCULATOR` 
            when :gamepad_1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_1` 
            when :gamepad_2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_2` 
            when :gamepad_3
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_3` 
            when :gamepad_4
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_4` 
            when :gamepad_5
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_5` 
            when :gamepad_6
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_6` 
            when :gamepad_7
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_7` 
            when :gamepad_8
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_8` 
            when :gamepad_9
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_9` 
            when :gamepad_10
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_10` 
            when :gamepad_11
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_11` 
            when :gamepad_12
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_12` 
            when :gamepad_13
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_13` 
            when :gamepad_14
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_14` 
            when :gamepad_15
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_15` 
            when :gamepad_16
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_16` 
            when :gamepad_16
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_16` 
            when :gamepad_a
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_A` 
            when :gamepad_b
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_B` 
            when :gamepad_c
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_C` 
            when :gamepad_l1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_L1` 
            when :gamepad_l2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_L2` 
            when :gamepad_mode
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_MODE` 
            when :gamepad_r1
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_R1` 
            when :gamepad_r2
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_R2` 
            when :gamepad_select
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_SELECT` 
            when :gamepad_start
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_START` 
            when :gamepad_thumbl
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_THUMBL` 
            when :gamepad_thumbr
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_THUMBR` 
            when :gamepad_x
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_X` 
            when :gamepad_y
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_Y` 
            when :gamepad_z
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BUTTON_Z` 
            when :brightness_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BRIGHTNESS_UP` 
            when :brightness_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BRIGHTNESS_DOWN` 
            when :break
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BREAK` 
            when :bookmark
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BOOKMARK` 
            when :avr_power
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_AVR_POWER` 
            when :avr_input
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_AVR_INPUT` 
            when :assist
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ASSIST` 
            when :app_switch
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_APP_SWITCH` 
            when :threeDmode
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_3D_MODE` 
            when :eleven
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_11` 
            when :twelve
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_12` 
            when :unknown
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_UNKNOWN` 
            when :soft_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SOFT_LEFT` 
            when :soft_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SOFT_RIGHT` 
            when :soft_sleep
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SOFT_SLEEP` 
            when :home
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_HOME` 
            when :forward
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_FORWARD` 
            when :back
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_BACK` 
            when :call
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CALL` 
            when :endcall
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ENDCALL` 
            when :dpad_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP` 
            when :dpad_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN` 
            when :dpad_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_LEFT` 
            when :dpad_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_RIGHT` 
            when :dpad_down_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN_LEFT` 
            when :dpad_down_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_DOWN_RIGHT` 
            when :dpad_up_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP_LEFT` 
            when :dpad_up_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_UP_RIGHT` 
            when :dpad_center
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DPAD_CENTER` 
            when :volume_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_VOLUME_UP` 
            when :volume_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_VOLUME_DOWN` 
            when :power
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_POWER` 
            when :camera
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CAMERA` 
            when :clear
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_CLEAR` 
            when :alt_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ALT_LEFT` 
            when :alt_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ALT_RIGHT` 
            when :shift_left
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SHIFT_LEFT` 
            when :shift_right
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SHIFT_RIGHT` 
            when :tab
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_TAB` 
            when :sym
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SYM` 
            when :explorer
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_EXPLORER` 
            when :envelope
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ENVELOPE` 
            when :enter
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_ENTER` 
            when :del
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_DEL` 
            when :headsethook
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_HEADSETHOOK` 
            when :focus
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_FOCUS` 
            when :menu
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MENU` 
            when :notification
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_NOTIFICATION` 
            when :search
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_SEARCH` 
            when :media_play_pause
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PLAY_PAUSE` 
            when :media_stop
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_STOP` 
            when :media_next
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_NEXT` 
            when :media_previous
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_PREVIOUS` 
            when :media_rewind
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_REWIND` 
            when :media_fast_forward
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MEDIA_FAST_FORWARD` 
            when :mute
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MUTE` 
            when :page_up
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PAGE_UP` 
            when :page_down
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PAGE_DOWN` 
            when :pictsymbols
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_PICTSYMBOLS` 
            when :move_home
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MOVE_HOME` 
            when :move_end
              str_resp = `#{$adb_path} shell input keyevent KEYCODE_MOVE_END` 
          else
            raise "ERROR: unknown special keycode: #{keycode}"
            return 1
          end
          return str_resp.to_s.scrub
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
          `#{$adb_path} shell getevent -l` 
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AndroidADB.adb_net_disconnect(
      #   :adb_path => 'required - path to adb binary (unless already set by another method)',
      #   :target => 'required - target host or IP to disconnect',
      #   :port => 'optional - defaults to tcp 5555'
      # )
      public
      def self.adb_net_disconnect(opts={})
        $adb_path = opts[:adb_path].to_s.scrub if File.exists?(opts[:adb_path].to_s.scrub)
        target = opts[:target].to_s.scrub
        if opts[:port]
          port = opts[:port].to_i
        else
          port = 5555
        end

        begin
          adb_response = `#{$adb_path} disconnect #{target}:#{port}` 

          return adb_response
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

          #{self}.adb_net_connect(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :target => 'required - target host or IP to connect',
            :port => 'optional - defaults to tcp 5555'
          )
 
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

          #{self}.input(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :string => 'required - string to type'
          )

          #{self}.input_special(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :keycode => 'required - special keycode to type (:zoom_in|:zoom_out|:zenkaku_hankaku|:yen|:window|:wakeup|:voice_assist|:tv_zoom_mode|:tv_timer_programming|:tv_terrestrial_digital|:tv_terrestrial_analog|:tv_satellite_teletext|:tv_satellite_service|:tv_satellite|:tv_satellite_bs|:tv_satellite_cs|:tv_radio_service|:tv_power|:tv_number_entry|:tv_network|:tv_media_context_menu|:tv_input_vga_1|:tv_input_hdmi_1|:tv_input_hdmi_2|:tv_input_hdmi_3|:tv_input_hdmi_4|:tv_input_composite_1|:tv_input_composite_2|:tv_input_component_1|:tv_input_component_2|:tv_input|:tv_data_service|:tv_contents_menu|:tv_audio_desc|:tv_audio_desc_mix_up|:tv_audio_desc_mix_down|:tv_antenna_cable|:tv|:sysrq|:switch_charset|:stem_primary|:stem1|:stem2|:stem3|:stb_power|:stb_input|:sleep|:settings|:scroll_lock|:ro|:prog_blue|:prog_green|:prog_red|:prog_yellow|:pairing|:num_lock|:numpad_subtract|:numpad_multiply|:numpad_left_paren|:numpad_right_paren|:numpad_equals|:numpad_enter|:numpad_dot|:numpad_comma|:numpad_add|:numpad0|:numpad1|:numpad2|:numpad3|:numpad4|:numpad5|:numpad6|:numpad7|:numpad8|:numpad9|:num|:nav_in|:nav_next|:nav_out|:nav_previous|:music|:muhenkan|:meta_left|:meta_right|:media_top_menu|:media_step_forward|:media_step_back|:media_skip_forward|:media_skip_back|:media_record|:media_play|:media_eject|:media_close|:media_audio_track|:manner_mode|:last_channel|:language_switch|:katakana_hiragana|:kana|:insert|:info|:henkan|:help|:guide|:forward_del|:f1|:f2|:f3|:f4|:f5|:f6|:f7|:f8|:f9|:f10|:f11|:f12|:escape|:eisu|:dvr|:ctrl_left|:ctrl_right|:cut|:copy|:paste|:contacts|:chan_down|:chan_up|:captions|:caps_lock|:calendar|:calculator|:gamepad_1|:gamepad_2|:gamepad_3|:gamepad_4|:gamepad_5|:gamepad_6|:gamepad_7|:gamepad_8|:gamepad_9|:gamepad_10|:gamepad_11|:gamepad_12|:gamepad_13|:gamepad_14|:gamepad_15|:gamepad_16|:gamepad_a|:gamepad_b|:gamepad_c|:gamepad_l1|:gamepad_l2|:gamepad_mode|:gamepad_r1|:gamepad_r2|:gamepad_select|:gamepad_start|:gamepad_thumbl|:gamepad_thumbr|:gamepad_x|:gamepad_y|:gamepad_z|:brightness_up|:brightness_down|:break|:bookmark|:avr_power|:avr_input|:assist|:app_switch|:threeDmode|:eleven|:twelve|:unknown|:soft_left|:soft_right|:soft_sleep|:home|:forward|:back|:call|:endcall|:dpad_up|:dpad_down|:dpad_left|:dpad_right|:dpad_down_left|:dpad_down_right|:dpad_up_left|:dpad_up_right|:dpad_center|:volume_up|:volume_down|:power|:camera|:clear|:alt_left|:alt_right|:shift_left|:shift_right|:tab|:sym|:explorer|:envelope|:enter|:del|:headsethook|:focus|:menu|:notification|:search|:media_play_pause|:media_stop|:media_next|:media_previous|:media_rewind|:media_fast_forward|:mute|:page_up|:page_down|:pictsymbols|:move_home|:move_end) see https://developer.android.com/reference/android/view/KeyEvent.html for more info'
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

          #{self}.adb_net_disconnect(
            :adb_path => 'required - path to adb binary (unless already set by another method)',
            :target => 'required - target host or IP to connect',
            :port => 'optional - defaults to tcp 5555'
          )
 
          #{self}.authors
        }
      end
    end
  end
end
