# frozen_string_literal: true

require 'serialport'

module CSI
  module Plugins
    # This plugin is used for interacting with serial devices including, but not limited to,
    # modems (including cellphone radios), legacy equipment, arduinos, & other misc ftdi devices
    module Serial
      # @session_data = ""
      @session_data = []

      # Supported Method Parameters::
      # serial_obj = CSI::Plugins::Serial.connect(
      #   block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)',
      #   baud: 'optional (defaults to 9600)',
      #   data_bits: 'optional (defaults to 8)',
      #   stop_bits: 'optional (defaults to 1)',
      #   parity: 'optional (defaults to SerialPort::NONE)',
      #   flow_control: 'optional (defaults to SerialPort::HARD) SerialPort::NONE|SerialPort::SOFT|SerialPort::HARD'
      # )

      public

      def self.connect(opts = {})
        if opts[:block_dev].nil?
          block_dev = '/dev/ttyUSB0'
        else
          block_dev = opts[:block_dev].to_s if File.exist?(opts[:block_dev].to_s)
        end

        baud = if opts[:baud].nil?
                 9600
               else
                 opts[:baud].to_i
               end

        data_bits = if opts[:data_bits].nil?
                      8
                    else
                      opts[:data_bits].to_i
                    end

        stop_bits = if opts[:stop_bits].nil?
                      1
                    else
                      opts[:stop_bits].to_i
                    end

        parity = if opts[:parity].nil?
                   SerialPort::NONE
                 else
                   opts[:parity]
                 end

        flow_control = if opts[:flow_control].nil?
                         SerialPort::HARD
                       else
                         opts[:flow_control]
                       end

        serial_conn = SerialPort.new(
          block_dev,
          baud,
          data_bits,
          stop_bits,
          parity,
          flow_control
        )

        serial_obj = {}
        serial_obj[:serial_conn] = serial_conn
        serial_obj[:session_thread] = init_session_thread(serial_conn: serial_conn)

        return serial_obj
      rescue => e
        disconnect(serial_obj: serial_obj) unless serial_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # session_thread = init_session_thread(
      #   serial_conn: 'required SerialPort.new object'
      # )

      private_class_method def self.init_session_thread(opts = {})
        serial_conn = opts[:serial_conn]

        # Spin up a serial_obj session_thread
        session_thread = Thread.new do
          # serial_conn.flush # TODO: flush
          serial_conn.read_timeout = 100
          this_session_data = ''
          loop do
            IO.select([serial_conn])
            # @session_data << serial_conn.read.to_s.scrub
            @session_data << serial_conn.read.to_s.scrub
          end
        end

        return session_thread
      rescue => e
        session_thread&.terminate
        serial_conn&.close
        serial_conn = nil

        raise e.message
      end

      # Supported Method Parameters::
      # line_state = CSI::Plugins::Serial.get_line_state(
      #   serial_obj: 'required serial_obj returned from #connect method'
      # )

      public

      def self.get_line_state(opts = {})
        serial_obj = opts[:serial_obj]
        serial_conn = serial_obj[:serial_conn]
        serial_conn.get_signals
      rescue => e
        disconnect(serial_obj: serial_obj) unless serial_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # modem_params = CSI::Plugins::Serial.get_modem_params(
      #   serial_obj: 'required serial_obj returned from #connect method'
      # )

      public

      def self.get_modem_params(opts = {})
        serial_obj = opts[:serial_obj]
        serial_conn = serial_obj[:serial_conn]
        serial_conn.get_modem_params
      rescue => e
        disconnect(serial_obj: serial_obj) unless serial_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Serial.request(
      #   serial_obj: 'required serial_obj returned from #connect method',
      #   request: 'required string to write to serial device'
      # )

      public

      def self.request(opts = {})
        serial_obj = opts[:serial_obj]
        request = opts[:request].to_s.scrub
        serial_conn = serial_obj[:serial_conn]
        chars_written = serial_conn.write(request)
        sleep 3
        return chars_written
      rescue => e
        disconnect(serial_obj: serial_obj) unless serial_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Serial.response(
      #   serial_obj: 'required serial_obj returned from #connect method'
      # )

      public

      def self.response(opts = {})
        serial_obj = opts[:serial_obj]
        response = @session_data[-1]

        return response
      rescue => e
        disconnect(serial_obj: serial_obj) unless serial_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # session_data = CSI::Plugins::Serial.dump_session_data

      public

      def self.dump_session_data
        @session_data
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # session_data = CSI::Plugins::Serial.flush_session_data

      public

      def self.flush_session_data
        @session_data.clear
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Serial.disconnect(
      #   serial_obj: 'required serial_obj returned from #connect method'
      # )

      public

      def self.disconnect(opts = {})
        serial_obj = opts[:serial_obj]
        serial_conn = serial_obj[:serial_conn]
        session_thread = serial_obj[:session_thread]
        flush_session_data
        session_thread.terminate
        serial_conn.close
        serial_conn = nil
      rescue => e
        raise e.message
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
          serial_obj = #{self}.connect(
            block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)',
            baud: 'optional (defaults to 9600)',
            data_bits: 'optional (defaults to 8)',
            stop_bits: 'optional (defaults to 1)',
            parity: 'optional (defaults to SerialPort::NONE)',
            flow_control: 'optional (defaults to SerialPort::NONE)'
          )

          line_state = #{self}.get_line_state(
            serial_obj: 'required serial_obj returned from #connect method'
          )

          modem_params = #{self}.get_modem_params(
            serial_obj: 'required serial_obj returned from #connect method'
          )

          #{self}.request(
            serial_obj: 'required serial_obj returned from #connect method',
            request: 'required string to write to serial device'
          )

          #{self}.response(
            serial_obj: 'required serial_obj returned from #connect method'
          )

          session_data_arr = #{self}.dump_session_data

          #{self}.flush_session_data

          #{self}.disconnect(
            serial_obj: 'required serial_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
