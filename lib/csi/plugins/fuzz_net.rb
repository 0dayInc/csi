# frozen_string_literal: true

require 'socket'

module CSI
  module Plugins
    # This plugin was created to support fuzzing various networking protocols
    module FuzzNet
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::Hexify.connect(
      #   target: 'required = target host or ip',
      #   port: 'required => target port',
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

      # TODO: create actual fuzzing logic for fuzz_net object
      # Supported Method Parameters::
      # fuzz_net_obj = CSI::Plugins::Hexify.disconnect(
      #   fuzz_net_obj: 'required = fuzz_net_obj returned from #connect method'
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

          fuzz_net = #{self}.disconnect(
            fuzz_net_obj: 'required = fuzz_net_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
