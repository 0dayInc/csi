# frozen_string_literal: true

require 'base64'
require 'cgi'
require 'htmlentities'

module CSI
  module Plugins
    # This plugin was created to support fuzzing various networking protocols
    module Fuzz
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # socket_fuzz_results_arr = CSI::Plugins::Fuzz.socket(
      #   target: 'required - target host or ip',
      #   port: 'required - target port',
      #   protocol: 'optional - :tcp || :udp (defaults to tcp)',
      #   tls: 'optional - boolean connect to target socket using TLS (defaults to false)',
      #   request: 'required - String object of socket request w/ \u9999 as position delimeter (e.g. "GET /\u9999FUZZ\u9999 HTTP/1.1\r\nHost: \u9999127.0.0.1\u9999\r\n\r\n")',
      #   payload: 'required - payload string',
      #   encoding: 'optional - :base64 || :html_entity || :url (Defaults to nil)',
      #   response_timeout: 'optional - float (defaults to 0.9)',
      #   request_rate_limit: 'optional - float (defaults to 0.9)'
      # )

      public_class_method def self.socket(opts = {})
        target = opts[:target].to_s.scrub
        port = opts[:port].to_i
        protocol = opts[:protocol]
        tls = opts[:tls]
        request = opts[:request].to_s
        payload = opts[:payload].to_s
        opts[:encoding].nil? ? encoding = nil : encoding = opts[:encoding].to_s.strip.chomp.scrub.downcase.to_sym

        if encoding
          case encoding
          when :base64
            payload = Base64.strict_encode64(payload)
          when :html_entity
            payload = HTMLEntities.new.encode(payload)
          when :url
            payload = CGI.escape(payload)
          else
            raise "encoding type: #{opts[:encoding]} not supported."
          end
        end

        delimeter = "\u9999"
        opts[:response_timeout].nil? ? response_timeout = 0.9 : response_timeout = opts[:response_timeout].to_f
        opts[:request_rate_limit].nil? ? request_rate_limit = 0.9 : request_rate_limit = opts[:request_rate_limit].to_f
        socket_fuzz_results_arr = []

        request_delim_index_arr = []
        request.each_char.with_index do |char, char_index|
          request_delim_index_arr.push(char_index) if char == delimeter
        end

        # Ensure this_request object is properly scoped for rescue Errno::ECONNRESET
        this_request = ''

        # request_delim_index_arr should always return an even length,
        # otherwise the request is missing a position delimeter.
        request_delim_index_arr.each_slice(2).with_index do |placeholder_slice, placeholder_slice_index|
          this_socket_fuzz_result = {}
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
          sock_obj = CSI::Plugins::Sock.connect(
            target: target,
            port: port,
            protocol: protocol,
            tls: tls
          )

          this_socket_fuzz_result[:timestamp] = Time.now.strftime('%Y-%m-%d %H:%M:%S.%9N %z').to_s
          this_socket_fuzz_result[:request] = this_request.to_s.inspect
          this_socket_fuzz_result[:request_len] = this_request.length
          sock_obj.print(this_request)
          does_respond = IO.select([sock_obj], nil, nil, response_timeout)
          if does_respond
            response = sock_obj.read.to_s.inspect
            response_len = response.length
            this_socket_fuzz_result[:response] = response
            this_socket_fuzz_result[:response_len] = response_len
          else
            this_socket_fuzz_result[:response] = ''
            this_socket_fuzz_result[:response_len] = 0
          end
          # TODO: dump into file once array reaches max length (avoid memory consumption issues)
          socket_fuzz_results_arr.push(this_socket_fuzz_result)
        end

        return socket_fuzz_results_arr
      rescue => e
        e.class == NoMethodError ? response = "#{e.class}: #{e.message} #{e.backtrace}" : response = "#{e.class}: #{e.message}"
        this_socket_fuzz_result = {}
        this_socket_fuzz_result[:timestamp] = Time.now.strftime('%Y-%m-%d %H:%M:%S.%9N %z').to_s
        this_socket_fuzz_result[:request] = this_request.to_s.inspect
        this_socket_fuzz_result[:request_len] = this_request.length
        this_socket_fuzz_result[:response] = response
        this_socket_fuzz_result[:response_len] = response.length
        socket_fuzz_results_arr.push(this_socket_fuzz_result)
        return socket_fuzz_results_arr
      ensure
        sleep request_rate_limit
        sock_obj = CSI::Plugins::Sock.disconnect(sock_obj: sock_obj) unless sock_obj.nil?
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
          socket_fuzz_results_arr = #{self}.socket(
            target: 'required = target host or ip',
            port: 'required => target port',
            protocol: 'optional => :tcp || :udp (defaults to tcp)',
            tls: 'optional - boolean connect to target socket using TLS (defaults to false)',
            request: 'required - String object of socket request w/ \\u9999 as position delimeter (e.g. \"GET /\u9999FUZZ\u9999 HTTP/1.1\\r\\nHost: \u9999127.0.0.1\u9999\\r\\n\\r\\n\")',
            payload: 'required - payload string',
            encoding: 'optional - :base64 || :html_entity || :url (Defaults to nil)',
            response_timeout: 'optional - float (defaults to 0.9)',
            request_rate_limit: 'optional - float (defaults to 0.9)'
          )

          #{self}.authors
        "
      end
    end
  end
end
