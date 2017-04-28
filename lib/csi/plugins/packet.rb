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
          pcap[0].public_methods
          pcap.each do |p|
            print \"IP ID: \#{p.ip_id_readable} \"
            print \"IP Sum: \#{p.ip_sum_readable} \"
            print \"SRC IP: \#{p.ip_src_readable} \"
            print \"SRC MAC: (\#{p.eth_src_readable}) \"
            print \"TCP SRC PORT: \#{p.tcp_sport} => \"
            print \"DST IP: \#{p.ip_dst_readable} \"
            print \"DST MAC: (\#{p.eth_dst_readable}) \"
            print \"TCP DST PORT: \#{p.tcp_dport} \"
            print \"ETH PROTO: \#{p.eth_proto_readable} \"
            print \"TCP FLAGS: \#{p.tcp_flags_readable} \"
            print \"TCP ACK: \#{p.tcp_ack_readable} \"
            print \"TCP SEQ: \#{p.tcp_seq_readable} \"
            print \"TCP SUM: \#{p.tcp_sum_readable} \"
            print \"TCP OPTS: \#{p.tcp_opts_readable} \"
            puts \"BODY: \#{p.hexify(p.payload)}\"
            puts \"\\n\\n\\n\"
          end
        "
      end
    end
  end
end
