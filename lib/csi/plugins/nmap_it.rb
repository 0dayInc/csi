require 'nmap'

module CSI
  module Plugins
    # This plugin is used as an  interface to nmap, the exploration tool and security / port scanner.
    module NmapIt
      # Supported Method Parameters::
      # CSI::Plugins::NmapIt.port_scan do |nmap|
          puts nmap.public_methods
      # end
      public
      def self.port_scan
        Nmap::Program.scan do |nmap|
          yield(nmap)
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::NmapIt.parse_xml_results(:xml_file => 'required - path to nmap xml results') do |xml|
          puts xml.public_methods
      # end
      public
      def self.parse_xml_results(opts={})
        xml_file = opts[:xml_file].to_s.scrub.strip.chomp if File.exists?(opts[:xml_file].to_s.scrub.strip.chomp)

        Nmap::XML.new do |xml|
          yield(xml)
        end
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = %Q{AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        }

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          #{self}.port_scan do |nmap|
            puts nmap.public_methods
            nmap.connect_scan = true
            nmap.service_scan = true
            nmap.verbose = true
            nmap.ports = [1..1024,1337]
            nmap.targets = '127.0.0.1'
            nmap.xml = '/tmp/nmap_port_scan_res.xml'
          end

          #{self}.authors
        }
      end
    end
  end
end
