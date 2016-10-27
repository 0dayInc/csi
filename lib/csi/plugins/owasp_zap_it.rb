# frozen_string_literal: true
require 'json'
require 'owasp_zap'
include OwaspZap

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZapIt
      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.start(
      #   :zap_bin_path => 'required - path to zap.sh file'
      #   :target => 'required - target URL to test',
      #   :output_path => 'optional - alternative file path to dump output (defaults to /tmp/owasp_zap.output)',
      #   :headless => 'optional - run zap headless if set to true',
      #   :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)',
      # )
      private
      def self.callback_when_pattern_in(opts={})
        file = opts[:file]
        pattern = opts[:pattern]

        File.open(file, 'r') do |file|
          file.seek(0, IO::SEEK_END) # rewinds file to the end
          loop do
            changes = file.read
            unless changes.empty?
              print changes
              break if changes.include?(pattern)
            end
            sleep 1
          end
        end

        return
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.start(
      #   :zap_bin_path => 'required - path to zap.sh file'
      #   :target => 'required - target URL to test',
      #   :output_path => 'optional - alternative file path to dump output (defaults to /tmp/owasp_zap.output)',
      #   :headless => 'optional - run zap headless if set to true',
      #   :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)',
      # )
      public
      def self.start(opts={})
        begin
          #api_key = opts[:api_key].to_s.scrub.strip.chomp # Waiting for https://github.com/vpereira/owasp_zap/issues/12 to be resolved :-/

          target = opts[:target].to_s.scrub.strip.chomp
          if opts[:headless]
            headless = true
          else
            headless = false
          end

          if opts[:output_path]
            @output_path = opts[:output_path].to_s.scrub.strip.chomp if File.exists?(File.dirname(opts[:output_path].to_s.scrub.strip.chomp))
          else
            @output_path = '/tmp/owasp_zap.output'
          end

          FileUtils.touch(@output_path) unless File.exists?(@output_path)

          if opts[:proxy]
            proxy = opts[:proxy].to_s.scrub.strip.chomp
            #zap_obj = Zap.new(:api_key => api_key, :target => target, :base => proxy)
            zap_obj = Zap.new(target: target, base: proxy, output: @output_path)
          else
            #zap_obj = Zap.new(:api_key => api_key, :target => target)
            zap_obj = Zap.new(target: target, output: @output_path)
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
            #zap_obj.start(:api_key => true, :daemon => true)
            zap_obj.start(daemon: true)
          else
            #zap_obj.start(:api_key => true)
            zap_obj.start
          end

          callback_when_pattern_in(
            file: @output_path,
            pattern: 'INFO org.parosproxy.paros.control.Control  - Create and Open Untitled Db'
          )

          return zap_obj
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
      # CSI::Plugins::OwaspZapIt.spider(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.spider(opts={})
        zap_obj = opts[:zap_obj]

        begin
          zap_obj.spider.start
          callback_when_pattern_in(
            file: @output_path,
            pattern: 'INFO org.zaproxy.zap.spider.Spider  - Spidering process is complete. Shutting down...'
          )

          return zap_obj
        rescue => e
          raise e.message
          return 1
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
          callback_when_pattern_in(
            file: @output_path,
            pattern: 'INFO org.parosproxy.paros.core.scanner.Scanner  - scanner completed'
          )

          return zap_obj
        rescue => e
          raise e.message
          return 1
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
          return 1
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

          callback_when_pattern_in(
            file: @output_path,
            pattern: 'INFO org.zaproxy.zap.extension.api.CoreAPI  - OWASP ZAP'
          )

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

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts "USAGE:
          zap_obj = #{self}.start(
            :zap_bin_path => 'required - path to zap.sh file',
            :target => 'required - target URL to test',
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
