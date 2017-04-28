# frozen_string_literal: true

require 'packetfu'
require 'packetfu/protos/ipv6'
require 'packetfu/protos/eth'

module CSI
  module Plugins
    # This plugin is used for interacting with PCAP files to map out and visualize in an 
    # automated fashion what comprises a infrastructure, network, and/or application
    module Packet
      # Supported Method Parameters::
      # pcap = CSI::Plugins::Packet.open_pcap_file(
      #   path: 'required - path to packet capture file'
      # )

      public

      def self.open_pcap_file(opts = {})
        path = opts[:path].to_s.scrub.strip.chomp if File.exist?(opts[:path].to_s.scrub.strip.chomp)

        pcap = PacketFu::PcapFile.read_packets(path)

        return pcap
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
          pcap = #{self}.open_pcap_file(
            path: 'required - path to packet capture file'
          )
        "
      end
    end
  end
end
