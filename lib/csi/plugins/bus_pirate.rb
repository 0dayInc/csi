# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin is used for interacting with Bus Pirate v3.6
    # This plugin may be compatible with other versions, however, 
    # has not been tested with anything other than v3.6.
    module BusPirate

      # Supported Method Parameters::
      # bus_pirate_obj = CSI::Plugins::BusPirate.connect(
      #   block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)'
      # )

      public_class_method def self.connect(opts = {})
        if opts[:block_dev].nil?
          block_dev = '/dev/ttyUSB0'
        else
          block_dev = opts[:block_dev].to_s if File.exist?(opts[:block_dev].to_s)
        end

        bus_pirate_obj = CSI::Plugins::Serial.connect(block_dev: block_dev)

        return bus_pirate_obj
      rescue => e
        disconnect(bus_pirate_obj: bus_pirate_obj) unless bus_pirate_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BusPirate.disconnect(
      #   bus_pirate_obj: 'required bus_pirate_obj returned from #connect method'
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
          bus_pirate_obj = #{self}.connect(
            block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)'
          )

          #{self}.disconnect(
            bus_pirate_obj: 'required bus_pirate_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
