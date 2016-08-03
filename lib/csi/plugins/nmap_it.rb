require 'nmap'

module CSI
  module Plugins
    # This plugin is used as an  interface to nmap, the exploration tool and security / port scanner.
    module NmapIt
      # Supported Method Parameters::
      # CSI::Plugins::NmapIt.port_scan(
      #   :port_range => 'optional - array containing range of ports e.g. [1..65535]'
      # )
      public
      def self.port_scan
        Nmap::Program.scan do |nmap|
          yield(nmap)
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
            nmap.syn_scan = true
            nmap.service_scan = true
            nmap.os_fingerprint = true
            nmap.verbose = true
            nmap.ports = [1..1024,1337]
            nmap.targets = '127.0.0.1'
            nmap.xml = '~/nmap_port_scan_res.xml'
          end

          #{self}.authors
        }
      end
    end
  end
end
