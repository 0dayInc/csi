# frozen_string_literal: true
require 'pty'
require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZap
      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.start(
      #   :api_key => 'required - api key for API authorization',
      #   :zap_bin_path => 'optional - path to zap.sh file'
      #   :output_path => 'optional - alternative file path to dump output (defaults to /tmp/owasp_zap.output)',
      #   :headless => 'optional - run zap headless if set to true',
      #   :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)',
      # )

      public

      def self.start(opts = {})
        zap_obj = {}

        api_key = opts[:api_key].to_s.scrub.strip.chomp
        zap_obj[:api_key] = api_key

        headless = if opts[:headless]
                     true
                   else
                     false
                   end

        if opts[:output_path]
          @output_path = opts[:output_path].to_s.scrub.strip.chomp if File.exist?(File.dirname(opts[:output_path].to_s.scrub.strip.chomp))
        else
          @output_path = '/tmp/owasp_zap.output'
        end

        begin
          FileUtils.touch(@output_path) unless File.exist?(@output_path)

          if opts[:zap_bin_path]
            zap_bin_path = opts[:zap_bin_path].to_s.scrub.strip.chomp if File.exist?(opts[:zap_bin_path].to_s.scrub.strip.chomp)
          else
            underlying_os = CSI::Plugins::DetectOS.type

            case underlying_os
            when :osx
              zap_bin_path = '/Applications/OWASP\ ZAP.app/Contents/Java/zap.sh'
            else
              raise "ERROR: zap.sh not found for #{underlying_os}. Please pass the :zap_bin_path parameter to this method for proper execution"
              exit 1
            end
          end

          if headless
            owasp_zap_cmd = "#{zap_bin_path} -daemon"
          else
            owasp_zap_cmd = "#{zap_bin_path}"
          end

          if opts[:proxy]
            proxy = opts[:proxy].to_s.scrub.strip.chomp
            proxy_uri = URI.parse(proxy)
            owasp_zap_cmd << " -host #{proxy_uri.host} -port #{proxy_uri.port}"
          end


          File.open(@output_path, 'w') do |file|
            PTY.spawn(owasp_zap_cmd) do |stdout, stdin, pid|
              zap_obj[:pid] = pid
              return_pattern = 'INFO org.parosproxy.paros.control.Control  - Create and Open Untitled Db'
              stdout.each do |line| 
                file.puts line
                if line.include?(return_pattern)
                  return zap_obj
                end
              end
            end
          end
        rescue SystemExit, Interrupt
          File.unlink(@output_path)
          exit 1
        rescue => e
          raise e.message
          File.unlink(@output_path)
          exit 1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.spider(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.spider(opts = {})
        zap_obj = opts[:zap_obj]

        begin
          return_pattern = 'INFO org.zaproxy.zap.spider.Spider  - Spidering process is complete. Shutting down...'
          return zap_obj
        rescue => e
          raise e.message
          return 1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.active_scan(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.active_scan(opts = {})
        zap_obj = opts[:zap_obj]

        begin
          return_pattern = 'INFO org.parosproxy.paros.core.scanner.Scanner  - scanner completed'
          return zap_obj
        rescue => e
          raise e.message
          return 1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.alerts(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.alerts(opts = {})
        zap_obj = opts[:zap_obj]

        begin
          return zap_obj.alerts.view
        rescue => e
          raise e.message
          return 1
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.stop(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.stop(opts = {})
        zap_obj = opts[:zap_obj]

        begin
          zap_obj.shutdown

          return_pattern = 'INFO org.zaproxy.zap.extension.api.CoreAPI  - OWASP ZAP'

          File.unlink(@output_path)
        rescue => e
          raise e.message
          File.unlink(@output_path)
          return 1
        end
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
          zap_obj = #{self}.start(
            :api_key => 'required - api key for API authorization',
            :zap_bin_path => 'optional - path to zap.sh file',
            :output_path => 'optional - alternative file path to dump output (defaults to /tmp/owasp_zap.output)',
            :headless => 'optional - run zap headless if set to true',
            :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)'
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
        "
      end
    end
  end
end
