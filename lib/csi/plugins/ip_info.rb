require 'ipaddr'

module CSI
  module Plugins
    # This plugin leverages ipinfo.io's REST API to discover information about IP addresses
    # 1,000 daily requests are allowed for free
    module IPInfo
      # Supported Method Parameters::
      # CSI::Plugins::IPInfo.get(
      #   :ip => 'required - IP to lookup'
      # )
      public
      def self.get
        ip = IPAddr.new(opts[:ip].to_s.scrub.strip.chomp)
        proxy = opts[:proxy]

        if ip.ipv4? || ip.ipv6?
          if proxy
            rest_client = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest, :proxy => proxy)
          else
            rest_client = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest)
          end
          ip_resp_str = rest_client.get("http://ipinfo.io/#{ip}")
          ip_resp_json = JSON.parse(ip_resp_str)

          return ip_resp_json
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
          #{self}.get(
            :ip => 'required - IP to lookup',
            :proxy => 'optional - use a proxy'
          )

          #{self}.authors
        }
      end
    end
  end
end
