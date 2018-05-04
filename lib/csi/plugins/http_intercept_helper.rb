# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin was created to generate UTF-8 characters for fuzzing
    module HTTPInterceptHelper
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # request_hash = CSI::Plugins::HTTPInterceptHelper.raw_to_hash(
      #   request_raw: 'required => raw http request string to convert to hash'
      # )

      public

      def self.raw_to_hash(opts = {})
        request_raw = opts[:request_raw].to_s
        request_hash = {}

        # Basic Parsing Begins
        raw_intercepted_request_arr = request_raw.split("\r\n")

        # Parse HTTP Protocol Request Line
        raw_request_line_arr = raw_intercepted_request_arr[0].split("\s")
        request_hash[:http_method] = raw_request_line_arr[0].to_s.upcase.to_sym
        request_hash[:http_resource_path] = URI.parse(raw_request_line_arr[1])
        request_hash[:http_version] = raw_request_line_arr[-1]

        # Begin Parsing HTTP Headers & Body (If Applicable)
        request_hash[:http_headers] = {}

        case request_hash[:http_method]
        when :CONNECT
          puts request_hash[:http_method]
        when :DELETE
          puts request_hash[:http_method]
        when :GET
          puts request_hash[:http_method]
        when :HEAD
          puts request_hash[:http_method]
        when :OPTIONS
          puts request_hash[:http_method]
        when :PATCH
          puts request_hash[:http_method]
        when :POST
          # Parse HTTP Headers
          raw_intercepted_request_arr[1..-1].each do |val|
            key = ''
            val.each_char do |char|
              break if char == ':'
              key = "#{key}#{char}"
            end

            header_val = val.gsub(/^#{key}:/, '').strip

            request_hash[:http_headers][key.to_sym] = header_val
          end

          # Parse HTTP Body
          raw_request_body = []
          raw_intercepted_request_arr[1..-1].each_with_index do |val, index|
            next if val != ''
            break_index = index + 2
            request_hash[:http_body] = raw_intercepted_request_arr[break_index..-1].join(',')
          end
        when :PUT
          puts request_hash[:http_method]
        when :TRACE
          puts request_hash[:http_method]
        else
          raise "HTTP Method: #{request_hash[:http_method]} Currently Unsupported>"
        end

        return request_hash
      rescue => e
        return e
      end

      # Supported Method Parameters::
      # request_raw = CSI::Plugins::HTTPInterceptHelper.hash_to_raw(
      #   request_hash: 'required => request_hash object returned by #raw_to_hash method'
      # )

      public

      def self.hash_to_raw(opts = {})
        request_hash = opts[:request_hash].to_s

        request_raw = ''
        request_raw = request_hash[:http_method]
        request_raw = "#{request_raw}#{request_hash[:http_resource_path]}"
        request_raw = "#{request_raw}#{request_hash[:http_version]}\r\n"
        request_hash[:http_headers].each do |key, header_val|
          request_raw = "#{request_raw}#{key}: #{header_val}\r\n"
        end

        if request_hash[:http_body] != ''
          request_raw = "#{request_raw}#{request_hash[:http_body]}"
        else
          request_raw = "#{request_raw}#\r\n"
        end

        return request_raw
      rescue => e
        return e
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
          request_hash = CSI::Plugins::HTTPInterceptHelper.raw_to_hash(
            request_raw: 'required => raw http request string to convert to hash'
          )

          request_raw = CSI::Plugins::HTTPInterceptHelper.hash_to_raw(
            request_hash: 'required => request_hash object returned by #raw_to_hash method'
          )
        "
      end
    end
  end
end
