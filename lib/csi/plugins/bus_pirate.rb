# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin is used for interacting with Bus Pirate v3.6
    # This plugin may be compatible with other versions, however,
    # has not been tested with anything other than v3.6.
    module BusPirate
      # Supported Method Parameters::
      # bus_pirate_obj = CSI::Plugins::BusPirate.connect_via_screen(
      #   screen_bin: 'optional - defaults to /usr/bin/screen'
      #   block_dev: 'optional - serial block device path (defaults to /dev/ttyUSB0)'
      # )

      public_class_method def self.connect_via_screen(opts = {})
        if opts[:block_dev].nil?
          block_dev = '/dev/ttyUSB0'
        else
          block_dev = opts[:block_dev].to_s if File.exist?(opts[:block_dev].to_s)
        end

        if opts[:screen_bin].nil?
          screen_bin = '/usr/bin/screen'
        else
          screen_bin = opts[:screen_bin].to_s.strip.chomp.scrub
        end

        raise "ERROR: #{screen_bin} not found." unless File.exist?(screen_bin)

        screen_params = "#{block_dev} 115200 8 N 1"
        system(screen_bin, screen_params)
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # bus_pirate_obj = CSI::Plugins::BusPirate.connect(
      #   block_dev: 'optional - serial block device path (defaults to /dev/ttyUSB0)'
      # )

      public_class_method def self.connect(opts = {})
        if opts[:block_dev].nil?
          block_dev = '/dev/ttyUSB0'
        else
          block_dev = opts[:block_dev].to_s if File.exist?(opts[:block_dev].to_s)
        end

        bus_pirate_obj = CSI::Plugins::Serial.connect(
          block_dev: block_dev,
          baud: '115200'
        )

        return bus_pirate_obj
      rescue => e
        disconnect(bus_pirate_obj: bus_pirate_obj) unless bus_pirate_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      #  CSI::Plugins::BusPirate.init_mode(
      #   bus_pirate_obj: 'required - bus_pirate_obj returned from #connect method'
      #   mode: 'required - bus pirate mode to invoke'
      # )
      public_class_method def self.init_mode(opts = {})
        bus_pirate_obj = opts[:bus_pirate_obj]
        mode = opts[:mode].to_s.strip.chomp.scrub.upcase

        case mode
        when 'BBI01'
          # Enter reset binary mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x00')
        when 'SPI1'
          # Enter binary SPI mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x01')
        when 'I2C1'
          # Enter I2C mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x02')
        when 'ART1'
          # Enter UART mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x03')
        when '1W01'
          # Enter 1-Wire mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x04')
        when 'RAW1'
          # Enter raw-wire mode
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x05')
        when 'RESET'
          # Reset Bus Pirate
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x0F')
        when 'STEST'
          # Bus Pirate self-tests
          CSI::Plugins::Serial.request(serial_obj: bus_pirate_obj, request: '\x10')
        else
          raise "Invalid mode: #{mode}"
        end

        mode_response = CSI::Plugins::Serial.response(serial_obj: bus_pirate_obj)

        return mode_response
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BusPirate.disconnect(
      #   bus_pirate_obj: 'required - bus_pirate_obj returned from #connect method'
      # )

      public_class_method def self.disconnect(opts = {})
        bus_pirate_obj = opts[:bus_pirate_obj]
        bus_pirate_obj = CSI::Plugins::Serial.disconnect(serial_obj: bus_pirate_obj)
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
          #{self}.connect_via_screen(
            screen_bin: 'optional - defaults to /usr/bin/screen'
            block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)'
          )

          bus_pirate_obj = #{self}.connect(
            block_dev: 'optional - serial block device path (defaults to /dev/ttyUSB0)'
          )

          #{self}.init_mode(
            bus_pirate_obj: 'required - bus_pirate_obj returned from #connect method'
            mode: 'required - bus pirate mode to invoke'
          )

          #{self}.disconnect(
            bus_pirate_obj: 'required - bus_pirate_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
