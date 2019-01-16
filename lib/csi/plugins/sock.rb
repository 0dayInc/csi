# frozen_string_literal: true

require 'socket'
require 'openssl'

module CSI
  module Plugins
    # This plugin was created to support fuzzing various networking protocols
    module Sock
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # sock_obj = CSI::Plugins::Sock.connect(
      #   target: 'required - target host or ip',
      #   port: 'required - target port',
      #   protocol: 'optional - :tcp || :udp (defaults to tcp)',
      #   tls: 'optional - boolean connect to target socket using TLS (defaults to false)'
      # )

      public_class_method def self.connect(opts = {})
        target = opts[:target].to_s.scrub
        port = opts[:port].to_i
        opts[:protocol].nil? ? protocol = :tcp : protocol = opts[:protocol].to_s.downcase.to_sym
        opts[:tls].nil? ? tls = false : tls = true

        case protocol
        when :tcp
          if tls
            sock = TCPSocket.open(target, port)
            tls_context = OpenSSL::SSL::SSLContext.new
            tls_context.set_params(verify_mode: OpenSSL::SSL::VERIFY_NONE)
            tls_sock = OpenSSL::SSL::SSLSocket.new(sock, tls_context)
            sock_obj = tls_sock.connect
          else
            sock_obj = TCPSocket.open(target, port)
          end
        when :udp
          sock_obj = UDPSocket.new
          sock_obj.connect(target, port)
        else
          raise "Unsupported protocol: #{protocol}"
        end

        return sock_obj
      rescue Errno::ECONNRESET
        sock_obj = disconnect(sock_obj: sock_obj) unless sock_obj.nil?
      rescue => e
        return e
      end

      # Supported Method Parameters::
      # sock_obj = CSI::Plugins::Sock.disconnect(
      #   sock_obj: 'required - sock_obj returned from #connect method'
      # )

      public_class_method def self.disconnect(opts = {})
        sock_obj = opts[:sock_obj]
        sock_obj.close
        sock_obj = nil
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
          sock_obj = #{self}.connect(
            target: 'required - target host or ip',
            port: 'required - target port',
            protocol: 'optional - :tcp || :udp (defaults to tcp)',
            tls: 'optional - boolean connect to target socket using TLS (defaults to false)'
          )

          sock_obj = CSI::Plugins::Sock.disconnect(
            sock_obj: 'required - sock_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
