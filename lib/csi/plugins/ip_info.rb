# frozen_string_literal: true

require 'ipaddress'
require 'resolv'

module CSI
  module Plugins
    # This plugin leverages ipinfo.io's REST API to discover information about IP addresses
    # 1,000 daily requests are allowed for free
    module IPInfo
      # Supported Method Parameters::
      # CSI::Plugins::IPInfo.get(
      #   ip: 'required - IP or Host to lookup',
      #   proxy: 'optional - use a proxy'
      # )

      private

      def self.ip_info_rest_call(opts = {})
        ip = opts[:ip].to_s.scrub.strip.chomp
        proxy = opts[:proxy]

        if IPAddress.valid?(ip)
          if proxy
            rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest, proxy: proxy)
          else
            rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)
          end
          ip_resp_str = rest_client.get("http://ipinfo.io/#{ip}")
          ip_resp_json = JSON.parse(ip_resp_str)

          return ip_resp_json
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # ip_info_struc = CSI::Plugins::IPInfo.get(
      #   ip_or_host: 'required - IP or Host to lookup',
      #   proxy: 'optional - use a proxy'
      # )

      public

      def self.get(opts = {})
        ip_or_host = opts[:ip_or_host].to_s.scrub.strip.chomp
        proxy = opts[:proxy]

        if IPAddress.valid?(ip_or_host)
          if proxy
            ip_resp_json = ip_info_rest_call(ip: ip_or_host, proxy: proxy)
          else
            ip_resp_json = ip_info_rest_call(ip: ip_or_host)
          end

          return ip_resp_json
        else
          host_resp_json = []
          Resolv::DNS.new.each_address(ip_or_host) do |ip|
            host_resp_json.push(
              ip_info_rest_call(ip: ip)
            )
          end
          if host_resp_json.length == 1
            return host_resp_json[0]
          else
            return host_resp_json
          end
        end
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
          ip_info_struc = #{self}.get(
            ip_or_host: 'required - IP or Host to lookup',
            proxy: 'optional - use a proxy'
          )

          #{self}.authors
        "
      end
    end
  end
end
