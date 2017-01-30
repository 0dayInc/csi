# frozen_string_literal: true
require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZap
      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.start(
      #   :file => 'required - callback file to read',
      #   :pattern => 'required - make the callback when this pattern is detected in the file',
      # )

      private

      def self.callback_when_pattern_in(opts = {})
        file = opts[:file]
        pattern = opts[:pattern]
        # iteration = 0

        File.open(file, 'r') do |file|
          file.flush # flush the Ruby output buffer for this stream
          file.sync = true # buffers are flushed after every write
          file.seek(0, IO::SEEK_END) # rewinds file to the end
          loop do
            changes = file.read
            unless changes.empty?
              print changes
              break if changes.include?(pattern)
            end
            sleep 1
            # iteration += 1
            # if changes.empty? && iteration == 9
            #   break # Something wrong w/ stdout in owasp_gem Gem
            # end
          end
        end

        nil
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.start(
      #   :api_key => 'required - api key for API authorization',
      #   :target => 'required - target URL to test',
      #   :zap_bin_path => 'optional - path to zap.sh file'
      #   :output_path => 'optional - alternative file path to dump output (defaults to /tmp/owasp_zap.output)',
      #   :headless => 'optional - run zap headless if set to true',
      #   :proxy => 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)',
      # )

      public

      def self.start(opts = {})
        api_key = opts[:api_key].to_s.scrub.strip.chomp

        target = opts[:target].to_s.scrub.strip.chomp
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

          if opts[:proxy]
            proxy = opts[:proxy].to_s.scrub.strip.chomp
          end

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

          zap_obj = {}
          if headless
            zap_obj[:pid] = Process.spawn("#{zap_bin_path} -daemon")
          else
            zap_obj[:pid] = Process.spawn(zap_bin_path)
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
      # CSI::Plugins::OwaspZap.spider(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.spider(opts = {})
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
      # CSI::Plugins::OwaspZap.active_scan(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.active_scan(opts = {})
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

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          zap_obj = #{self}.start(
            :api_key => 'required - api key for API authorization',
            :target => 'required - target URL to test',
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
