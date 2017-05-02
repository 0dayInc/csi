# frozen_string_literal: true

require 'packetfu'
require 'packetfu/protos/ipv6'
require 'packetfu/protos/eth'
require 'ipaddress'

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

      # Supported Method Parameters::
      # CSI::Plugins::Packet.send(
      #   src_ip: 'required - source ip of packet',
      #   dst_ip: 'required - destination ip to send packet',
      #   payload: 'optional - packet payload defaults to empty string',
      #   ip_id: 'optional - defaults to 0xfeed',
      #   int: 'optional - interface to send packet (defaults to eth0)',
      # )

      public

      def self.send(opts = {})
        src_ip = opts[:src_ip].to_s.scrub.strip.chomp if IPAddress.valid?(opts[:src_ip].to_s.scrub.strip.chomp) 
        dst_ip = opts[:dst_ip].to_s.scrub.strip.chomp if IPAddress.valid?(opts[:dst_ip].to_s.scrub.strip.chomp) 
        payload = opts[:payload].to_s

        if opts[:ip_id]
          ip_id = opts[:ip_id].to_s.scrub.strip.chomp
        else
          ip_id = '0xfeed'
        end

        if opts[:int]
          interface = opts[:int].to_s.scrub.strip.chomp
        else
          interface = 'eth0'
        end

        pkt = PacketFu::IPPacket.new

        pkt.ip_id = ip_id
        pkt.ip_saddr = src_ip
        pkt.ip_daddr = dst_ip
        pkt.payload = payload
        pkt.recalc

        pkt.to_w(interface)
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

          #{self}.send(
            src_ip: 'required - source ip of packet',
            dst_ip: 'required - destination ip to send packet',
            payload: 'optional - packet payload defaults to empty string',
            ip_id: 'optional - defaults to 0xfeed',
            int: 'optional - interface to send packet (defaults to eth0)',
          )
        "
      end
    end
  end
end
