# frozen_string_literal: true

require 'pty'
require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZap
      # Supported Method Parameters::
      # zap_rest_call(
      #   zap_obj: 'required zap_obj returned from #start method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private

      def self.zap_rest_call(opts = {})
        zap_obj = opts[:zap_obj]
        rest_call = opts[:rest_call].to_s.scrub
        http_method = if opts[:http_method].nil?
                        :get
                      else
                        opts[:http_method].to_s.scrub.to_sym
                      end
        params = opts[:params]
        http_body = opts[:http_body].to_s.scrub
        host = zap_obj[:host]
        port = zap_obj[:port]
        base_zap_api_uri = "http://#{host}:#{port}"

        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

        case http_method
        when :get
          response = rest_client.execute(
            method: :get,
            url: "#{base_zap_api_uri}/#{rest_call}",
            headers: {
              params: params
            },
            verify_ssl: false
          )

        when :post
          response = rest_client.execute(
            method: :post,
            url: "#{base_zap_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8'
            },
            payload: http_body,
            verify_ssl: false
          )

        else
          raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
        end
      rescue => e
        stop(zap_obj) unless zap_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.start(
      #   api_key: 'required - api key for API authorization',
      #   zap_bin_path: 'optional - path to zap.sh file'
      #   headless: 'optional - run zap headless if set to true',
      #   proxy: 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)',
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

        if opts[:zap_bin_path]
          zap_bin_path = opts[:zap_bin_path].to_s.scrub.strip.chomp if File.exist?(opts[:zap_bin_path].to_s.scrub.strip.chomp)
        else
          underlying_os = CSI::Plugins::DetectOS.type

          case underlying_os
          when :linux
            zap_bin_path = '/usr/share/zaproxy/zap.sh'
          when :osx
            zap_bin_path = '/Applications/OWASP ZAP.app/Contents/Java/zap.sh'
          else
            raise "ERROR: zap.sh not found for #{underlying_os}. Please pass the :zap_bin_path parameter to this method for proper execution"
          end
        end

        zap_bin = File.basename(zap_bin_path)
        zap_dir = File.dirname(zap_bin_path)

        if headless
          owasp_zap_cmd = "cd #{zap_dir} && ./#{zap_bin} -daemon"
        else
          owasp_zap_cmd = "cd #{zap_dir} && ./#{zap_bin}"
        end

        if opts[:proxy]
          proxy = opts[:proxy].to_s.scrub.strip.chomp
          proxy_uri = URI.parse(proxy)
          owasp_zap_cmd << " -host #{proxy_uri.host} -port #{proxy_uri.port}"
        else
          proxy = 'http://127.0.0.1:8080'
          proxy_uri = URI.parse(proxy)
        end
        zap_obj[:host] = proxy_uri.host.to_s.scrub
        zap_obj[:port] = proxy_uri.port.to_i

        zap_daemon_pid = ''
        PTY.spawn(owasp_zap_cmd) do |stdout, _stdin, pid|
          stdout.sync = true
          zap_daemon_pid = pid
          return_pattern = '[AWT-EventQueue-1] INFO hsqldb.db..ENGINE  - Database closed'
          stdout.each do |line|
            puts line
            Process.detach(pid) if line.include?(return_pattern)
          end
        end

        zap_obj[:pid] = zap_daemon_pid
        return zap_obj
      rescue => e
        stop(zap_obj) unless zap_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.spider(
      #   zap_obj: 'required - zap_obj returned from #open method',
      #   target: 'required - url to spider'
      # )

      public

      def self.spider(opts = {})
        zap_obj = opts[:zap_obj]
        target = opts[:target].to_s.scrub
        api_key = zap_obj[:api_key].to_s.scrub

        params = {
          zapapiformat: 'JSON',
          apikey: api_key,
          url: target,
          maxChildren: 9,
          recurse: 3,
          contextName: '',
          subtreeOnly: target
        }

        response = zap_rest_call(
          zap_obj: zap_obj,
          rest_call: 'JSON/spider/action/scan/',
          params: params
        )
      rescue => e
        stop(zap_obj) unless zap_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.active_scan(
      #   zap_obj: 'required - zap_obj returned from #open method'
      # )

      public

      def self.active_scan(opts = {})
        zap_obj = opts[:zap_obj]

        return_pattern = 'INFO org.parosproxy.paros.core.scanner.Scanner  - scanner completed'
        return zap_obj
      rescue => e
        stop(zap_obj) unless zap_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.alerts(
      #   zap_obj: 'required - zap_obj returned from #open method'
      # )

      public

      def self.alerts(opts = {})
        zap_obj = opts[:zap_obj]

        return zap_obj.alerts.view
      rescue => e
        stop(zap_obj) unless zap_obj.nil?
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.stop(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.stop(opts = {})
        zap_obj = opts[:zap_obj]
        pid = zap_obj[:pid]

        Process.kill('KILL', pid)
        Process.wait
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
          zap_obj = #{self}.start(
            api_key: 'required - api key for API authorization',
            zap_bin_path: 'optional - path to zap.sh file',
            headless: 'optional - run zap headless if set to true',
            proxy: 'optional - change local zap proxy listener (defaults to http://127.0.0.1:8080)'
          )
          puts zap_obj.public_methods

          #{self}.spider(
            zap_obj: 'required - zap_obj returned from #open method',
            target: 'required - url to spider'
          )

          #{self}.active_scan(
            zap_obj: 'required - zap_obj returned from #open method'
          )

          json_alerts = #{self}.alerts(
            zap_obj: 'required - zap_obj returned from #open method'
          )

          #{self}.stop(
            zap_obj: 'required - zap_obj returned from #open method'
          )

          #{self}.authors
        "
      end
    end
  end
end
