require 'json'
require 'owasp_zap'
include OwaspZap

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZapIt
      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.start(
      #   :api_key => 'required - api key generated w/in locally installed zap (found under preferences=>api)',
      #   :target => 'required - target URL to test',
      #   :headless => 'optional - run zap headless if set to true',
      #   :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1)',
      #   :zap_bin_path => 'required - path to zap.sh file'
      # )
      public
      def self.start(opts={})
        api_key = opts[:api_key].to_s.scrub.strip.chomp

        target = opts[:target].to_s.scrub.strip.chomp
        if opts[:headless]
          headless = true
        else
          headless = false
        end

        zap_obj = Zap.new(:api_key => api_key, :target => target)

        if opts[:proxy]
          proxy = opts[:proxy].to_s.scrub.strip.chomp
          zap_obj.base = proxy
        end

        if opts[:zap_bin_path]
          zap_bin_path = opts[:zap_bin_path].to_s.scrub.strip.chomp if File.exists?(opts[:zap_bin_path].to_s.scrub.strip.chomp)
          zap_obj.zap_bin = zap_bin_path
        else
          underlying_os = CSI::Plugins::DetectOS.type

          case underlying_os
            when :osx
              zap_obj.zap_bin = '/Applications/OWASP\ ZAP.app/Contents/Java/zap.sh'
          else
            raise "ERROR: zap.sh not found for #{underlying_os}. Please pass the :zap_bin_path parameter to this method for proper execution"
            exit 1
          end
        end

        if headless
          zap_obj.start(:api_key => true, :daemon => true)
        else
          zap_obj.start(:api_key => true)
        end

        return zap_obj
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.spider(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.spider(opts={})
        zap_obj = opts[:zap_obj]
        
        begin
          zap_obj.spider.start
        rescue => e
          raise e.message
          return -1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.active_scan(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.active_scan(opts={})
        zap_obj = opts[:zap_obj]
        
        begin
          zap_obj.ascan.start
        rescue => e
          raise e.message
          return -1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.alerts(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.alerts(opts={})
        zap_obj = opts[:zap_obj]
        
        begin
          return zap_obj.alerts.view
        rescue => e
          raise e.message
          return -1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.stop(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.stop(opts={})
        zap_obj = opts[:zap_obj]
        
        begin
          zap_obj.shutdown
        rescue => e
          raise e.message
          return -1
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
          zap_obj = #{self}.start(
            :api_key => 'required - api key generated w/in locally installed zap (found under preferences=>api)',
            :target => 'required - target URL to test',
            :headless => 'optional - run zap headless if set to true',
            :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1)'
          )
          puts zap_obj.public_methods

          #{self}.spider(
            :zap_obj => 'required - zap_obj returned from #open method'
          )

          #{self}.active_scan(
            :zap_obj => 'required - zap_obj returned from #open method'
          )

          json_alerts = #{self}.alerts(
            :zap_obj => 'required - zap_obj returned from #open method'
          )

          #{self}.stop(
            :zap_obj => 'required - zap_obj returned from #open method'
          )

          #{self}.authors
        }
      end
    end
  end
end
