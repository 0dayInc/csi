# frozen_string_literal: true

require 'socket'
require 'openssl'

module CSI
  module Plugins
    # This plugin was created to support fuzzing various networking protocols
    module Fuzz
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::Fuzz.connect(
      #   target: 'required - target host or ip',
      #   port: 'required - target port',
      #   protocol: 'optional - :tcp || :udp (defaults to tcp)',
      #   tls: 'optional - boolean connect to target socket using TLS (defaults to false)',
      # )

      private_class_method def self.connect(opts = {})
        target = opts[:target].to_s.scrub
        port = opts[:port].to_i
        opts[:protocol].nil? ? protocol = :tcp : protocol = opts[:protocol].to_s.downcase.to_sym
        opts[:tls] ? tls = true : tls = false

        case protocol
        when :tcp
          if tls
            sock = TCPSocket.new(target, port)
            tls_context = OpenSSL::SSL::SSLContext.new
            tls_context.set_params(verify_mode: OpenSSL::SSL::VERIFY_NONE)
            fuzz_net_obj = OpenSSL::SSL::SSLSocket.new(sock, tls_context)
          else
            fuzz_net_obj = TCPSocket.open(target, port)
          end
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
      # CSI::Plugins::Fuzz.socket(
      #   target: 'required - target host or ip',
      #   port: 'required - target port',
      #   protocol: 'optional - :tcp || :udp (defaults to tcp)',
      #   tls: 'optional - boolean connect to target socket using TLS (defaults to false)',
      #   request: 'required - String object of socket request w/ \u2764 as position delimeter (e.g. "GET /\u2764FUZZ\u2764 HTTP/1.1\r\nHost: \u2764127.0.0.1\u2764\r\n\r\n")',
      #   payload: 'required - payload string'
      # )

      public_class_method def self.socket(opts = {})
        target = opts[:target].to_s.scrub
        port = opts[:port].to_i
        protocol = opts[:protocol]
        tls = opts[:tls]
        request = opts[:request].to_s
        payload = opts[:payload].to_s
        delimeter = "\u2764"

        request_delim_index_arr = []
        request.each_char.with_index do |char, char_index|
          request_delim_index_arr.push(char_index) if char == delimeter
        end

        # request_delim_index_arr should always return an even length,
        # otherwise the request is missing a position delimeter.
        request_delim_index_arr.each_slice(2).with_index do |placeholder_slice, placeholder_slice_index|
          begin_delim_char_index_shift_width = placeholder_slice_index * 2
          begin_delim_char_index = placeholder_slice[0].to_i - begin_delim_char_index_shift_width

          end_delim_char_index_shift_width = (placeholder_slice_index * 2) + 2
          end_delim_char_index = placeholder_slice[1].to_i - end_delim_char_index_shift_width
          this_request = request.dup.delete(delimeter)
          if end_delim_char_index.positive?
            this_request[begin_delim_char_index..end_delim_char_index] = payload
          else
            # begin_delim_char_index should always be 0
            this_request[begin_delim_char_index] = payload
          end
          fuzz_net_obj = connect(
            target: target,
            port: port,
            protocol: protocol,
            tls: tls
          )

          # TODO: read response and dump to log file(s) for analysis of anomalies
          fuzz_net_obj.write(this_request)

          fuzz_net_obj = disconnect(fuzz_net_obj: fuzz_net_obj)
        end
      rescue => e
        return e
      end

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::Fuzz.disconnect(
      #   fuzz_net_obj: 'required - fuzz_net_obj returned from #connect method'
      # )

      private_class_method def self.disconnect(opts = {})
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
          #{self}.socket(
            target: 'required = target host or ip',
            port: 'required => target port',
            protocol: 'optional => :tcp || :udp (defaults to tcp)',
            tls: 'optional - boolean connect to target socket using TLS (defaults to false)',
            request: 'required - String object of socket request w/ \\u2764 (heart) as position delimeter (e.g. \"GET /\u2764FUZZ\u2764 HTTP/1.1\\r\\nHost: \u2764127.0.0.1\u2764\\r\\n\\r\\n\")',
            payload: 'required - payload string'
          )

          #{self}.authors
        "
      end
    end
  end
end
