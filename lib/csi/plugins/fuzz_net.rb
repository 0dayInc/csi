# frozen_string_literal: true

require 'socket'

module CSI
  module Plugins
    # This plugin was created to support fuzzing various networking protocols
    module FuzzNet
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::FuzzNet.connect(
      #   target: 'required - target host or ip',
      #   port: 'required - target port',
      #   protocol: 'optional => :tcp || :udp (defaults to tcp)'
      # )

      public_class_method def self.connect(opts = {})
        target = opts[:target].to_s.scrub
        port = opts[:port].to_i

        if opts[:protocol].nil?
          protocol = :tcp
        else
          protocol = opts[:protocol].to_s.downcase.to_sym
        end

        case protocol
        when :tcp
          fuzz_net_obj = TCPSocket.open(target, port)
        when :udp
          fuzz_net_obj = UDPSocket.new
          fuzz_net_obj.connect(target, port)
        else
          raise "Unsupported protocol: #{protocol}"
        end

        return fuzz_net_obj
      rescue => e
        return e
      end

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::FuzzNet.test_case(
      #   fuzz_net_obj: 'required - fuzz_net_obj returned from #connect method',
      #   request: 'required - String object of socket request w/ \u2764 as position delimeter (e.g. "GET /\u2764FUZZ\u2764 HTTP/1.1\r\nHost: \u2764127.0.0.1\u2764\r\n\r\n")',
      #   payload: 'required - payload string'
      # )

      public_class_method def self.test_case(opts = {})
        fuzz_net_obj = opts[:fuzz_net_obj]
        request = opts[:request].to_s
        payload = opts[:request].to_s

        request_delim_index_arr = []
        request.each_char.with_index do |char, char_index|
          request_delim_index_arr.push(char_index) if char == "\u2764"
        end

        # request_delim_index_arr should always return an even length,
        # otherwise the request is missing a position delimeter.
        request_delim_index_arr.each_slice(2).with_index do |placeholder_slice, placeholder_slice_index|
          begin_delim_char_index_shift_width = placeholder_slice_index * 2
          begin_delim_char_index = placeholder_slice[0].to_i - begin_delim_char_index_shift_width

          end_delim_char_index_shift_width = (placeholder_slice_index * 2) + 2
          end_delim_char_index = placeholder_slice[1].to_i - end_delim_char_index_shift_width
          this_request = request.dup.delete("\u2764")
          if end_delim_char_index.positive?
            this_request[begin_delim_char_index..end_delim_char_index] = payload
          else
            # begin_delim_char_index should always be 0
            this_request[begin_delim_char_index] = payload
          end
          fuzz_net_obj.write(this_request)
        end

        return fuzz_net_obj
      rescue => e
        return e
      end

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::FuzzNet.disconnect(
      #   fuzz_net_obj: 'required - fuzz_net_obj returned from #connect method'
      # )

      public_class_method def self.disconnect(opts = {})
        fuzz_net_obj = opts[:fuzz_net_obj]
        fuzz_net_obj.close
        fuzz_net_obj = nil
      rescue => e
        return e
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
          fuzz_net_obj = #{self}.connect(
            target: 'required = target host or ip',
            port: 'required => target port',
            protocol: 'optional => :tcp || :udp (defaults to tcp)'
          )

          fuzz_net_obj = CSI::Plugins::FuzzNet.test_case(
            fuzz_net_obj: 'required - fuzz_net_obj returned from #connect method',
            request: 'required - String object of socket request w/ \u2764 as position delimeter (e.g. \"GET /\u2764FUZZ\u2764 HTTP/1.1\r\nHost: \u2764127.0.0.1\u2764\r\n\r\n\")',
            payload: 'required - payload string'
          )

          fuzz_net = #{self}.disconnect(
            fuzz_net_obj: 'required = fuzz_net_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
