# frozen_string_literal: true

require 'pty'
require 'securerandom'
require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    # TODO: Convert all rest requests to POST instead of GET
    module OwaspZap
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # zap_rest_call(
      #   zap_obj: 'required zap_obj returned from #start method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private_class_method def self.zap_rest_call(opts = {})
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

        sleep 3

        return response
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
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
            zap_bin_path = '/Applications/OWASP\ ZAP.app/Contents/Java/zap.sh'
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
          owasp_zap_cmd = "#{owasp_zap_cmd} -host #{proxy_uri.host} -port #{proxy_uri.port}"
        else
          proxy = 'http://127.0.0.1:8080'
          proxy_uri = URI.parse(proxy)
        end
        zap_obj[:host] = proxy_uri.host.to_s.scrub
        zap_obj[:port] = proxy_uri.port.to_i

        csi_stdout_log_path = "/tmp/csi_plugins_owasp-#{SecureRandom.hex}.log"
        csi_stdout_log = File.new(csi_stdout_log_path, 'w')
        # Immediately writes all buffered data in IO to disk
        csi_stdout_log.sync = true
        csi_stdout_log.fsync

        fork_pid = Process.fork do
          begin
            PTY.spawn(owasp_zap_cmd) do |stdout, _stdin, _pid|
              stdout.each do |line|
                puts line
                csi_stdout_log.puts line
              end
            end
          rescue PTY::ChildExited, SystemExit, Interrupt, Errno::EIO
            puts 'Spawned OWASP Zap PTY exiting...'
            File.unlink(csi_stdout_log_path) if File.exist?(csi_stdout_log_path)
          rescue StandardError => e
            puts 'Spawned process exiting...'
            File.unlink(csi_stdout_log_path) if File.exist?(csi_stdout_log_path)
            raise e
          end
        end
        Process.detach(fork_pid)

        zap_obj[:pid] = fork_pid
        zap_obj[:stdout_log] = csi_stdout_log_path
        # This is how we'll know OWSAP Zap is in a ready state.
        if headless
          return_pattern = '[ZAP-daemon] INFO org.zaproxy.zap.DaemonBootstrap  - ZAP is now listening'
        else
          case underlying_os
          when :linux
            return_pattern = '[AWT-EventQueue-1] INFO hsqldb.db..ENGINE  - Database closed'
          when :osx
            return_pattern = '[AWT-EventQueue-0] INFO hsqldb.db..ENGINE  - Database closed'
          end
        end

        loop do
          if File.exist?(csi_stdout_log_path)
            return zap_obj if File.read(csi_stdout_log_path).include?(return_pattern)
          end
          sleep 3
        end
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
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

        spider = JSON.parse(response.body, symbolize_names: true)
        spider_id = spider[:scan].to_i

        loop do
          params = {
            apikey: api_key,
            scanId: spider_id
          }

          response = zap_rest_call(
            zap_obj: zap_obj,
            rest_call: 'JSON/spider/view/status/',
            params: params
          )

          spider = JSON.parse(response.body, symbolize_names: true)
          status = spider[:status].to_i
          puts "Spider ID: #{spider_id} => #{status}% Complete"
          break if status == 100
        end
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.active_scan(
      #   zap_obj: 'required - zap_obj returned from #open method',
      #   target:  'required - url to scan',
      #   scan_policy: 'optional - scan policy to use (defaults to Default Policy)'
      # )

      public

      def self.active_scan(opts = {})
        zap_obj = opts[:zap_obj]
        api_key = zap_obj[:api_key].to_s.scrub
        target = opts[:target]
        if opts[:scan_policy].nil?
          scan_policy = 'Default Policy'
        else
          scan_policy = opts[:scan_policy].to_s.scrub.strip.chomp
        end

        # TODO: Implement adding target to scope so that inScopeOnly can be changed to true
        params = {
          apikey: api_key,
          url: target,
          recurse: true,
          inScopeOnly: false,
          scanPolicyName: scan_policy
        }

        response = zap_rest_call(
          zap_obj: zap_obj,
          rest_call: 'JSON/ascan/action/scan/',
          params: params
        )

        active_scan = JSON.parse(response.body, symbolize_names: true)
        active_scan_id = active_scan[:scan].to_i

        loop do
          params = {
            apikey: api_key,
            scanId: active_scan_id
          }

          response = zap_rest_call(
            zap_obj: zap_obj,
            rest_call: 'JSON/ascan/view/status/',
            params: params
          )

          active_scan = JSON.parse(response.body, symbolize_names: true)
          status = active_scan[:status].to_i
          puts "Active Scan ID: #{active_scan_id} => #{status}% Complete"
          break if status == 100
        end
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.alerts(
      #   zap_obj: 'required - zap_obj returned from #open method',
      #   target: 'required - base url to return alerts'
      # )

      public

      def self.alerts(opts = {})
        zap_obj = opts[:zap_obj]
        api_key = zap_obj[:api_key].to_s.scrub
        target = opts[:target]

        params = {
          apikey: api_key,
          url: target
        }

        response = zap_rest_call(
          zap_obj: zap_obj,
          rest_call: 'JSON/core/view/alerts/',
          params: params
        )

        json_alerts = JSON.parse(response.body, symbolize_names: true)

        return json_alerts
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # report_path = CSI::Plugins::OwaspZap.generate_report(
      #   zap_obj: 'required - zap_obj returned from #open method',
      #   output_dir: 'required - directory to save report',
      #   report_type: 'required - <html|markdown|xml>'
      # )

      public

      def self.generate_report(opts = {})
        zap_obj = opts[:zap_obj]
        api_key = zap_obj[:api_key].to_s.scrub
        output_dir = opts[:output_dir] if Dir.exist?(opts[:output_dir])
        report_type = opts[:report_type].to_s.strip.chomp.scrub.to_sym

        params = {
          apikey: api_key
        }

        case report_type
        when :html
          report_path = "#{output_dir}/OWASP_Zap_Results.html"
          rest_call = 'OTHER/core/other/htmlreport/'
        when :markdown
          report_path = "#{output_dir}/OWASP_Zap_Results.md"
          rest_call = 'OTHER/core/other/mdreport/'
        when :xml
          report_path = "#{output_dir}/OWASP_Zap_Results.xml"
          rest_call = 'OTHER/core/other/xmlreport/'
        else
          raise @@logger.error("ERROR: Unsupported report type: #{report_type}\nValid report types are <html|markdown|xml>")
        end

        response = zap_rest_call(
          zap_obj: zap_obj,
          rest_call: rest_call,
          params: params
        )

        File.open(report_path, 'w') do |f|
          f.puts response.body
        end

        return report_path
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.intercept(
      #   zap_obj: 'required - zap_obj returned from #open method',
      #   domain: 'required - FQDN to intercept (e.g. test.domain.local)',
      #   enabled: 'optional - boolean (defaults to true)'
      # )

      public

      def self.intercept(opts = {})
        zap_obj = opts[:zap_obj]
        api_key = zap_obj[:api_key].to_s.scrub
        domain = opts[:domain]
        enabled = opts[:enabled]

        enabled = true if enabled.nil?
        enabled ? (action = 'addHttpBreakpoint') : (action = 'removeHttpBreakpoint')

        zap_rest_call(
          zap_obj: zap_obj,
          rest_call: "JSON/break/action/#{action}/?zapapiformat=JSON&apikey=#{api_key}&string=#{domain}&location=url&match=contains&inverse=false&ignorecase=true",
          http_method: :get
        )
      rescue StandardError, SystemExit, Interrupt => e
        stop(zap_obj) unless zap_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # watir_resp = CSI::Plugins::TransparentBrowser.nonblocking_watir(
      #   browser_obj: 'required - browser_obj w/ browser_type: :firefox||:headless returned from #open method',
      #   instruction: 'required - watir instruction to make (e.g. button(text: "Google Search").click)'
      # )

      public

      def self.nonblocking_watir(opts = {})
        this_browser_obj = opts[:browser_obj]
        instruction = opts[:instruction].to_s.strip.chomp.scrub

        raise "\nbrowser_obj.class == #{this_browser_obj.class} browser_obj == #{this_browser_obj}\n#{self}.nonblocking_goto only supports browser_obj.class == Watir::Browser" unless this_browser_obj.is_a?(Watir::Browser)
        raise "\nthis_browser_obj.driver.browser == #{this_browser_obj.driver.browser}\n#{self}.nonblocking_goto only supports this_browser_obj.driver.browser == :firefox" unless this_browser_obj.driver.browser == :firefox

        timeout = 0
        # this_browser_obj.driver.manage.timeouts.implicit_wait = timeout
        this_browser_obj.driver.manage.timeouts.page_load = timeout
        # this_browser_obj.driver.manage.timeouts.script_timeout = timeout

        watir_resp = this_browser_obj.instance_eval(instruction)
      rescue Timeout::Error
        # Now set all the timeouts back to default:
        # this_browser_obj.driver.manage.timeouts.implicit_wait = b.driver.capabilities[:implicit_timeout]
        this_browser_obj.driver.manage.timeouts.page_load = this_browser_obj.driver.capabilities[:page_load_timeout]
        # this_browser_obj.driver.manage.timeouts.script_timeout = b.driver.capabilities[:script_timeout]

        return watir_resp
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZap.stop(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )

      public

      def self.stop(opts = {})
        zap_obj = opts[:zap_obj]
        unless zap_obj.nil?
          pid = zap_obj[:pid]
          File.unlink(zap_obj[:stdout_log]) if File.exist?(zap_obj[:stdout_log])

          Process.kill('TERM', pid)
        end
      rescue StandardError => e
        raise e
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
            target: 'required - url to scan',
            scan_policy: 'optional - scan policy to use (defaults to Default Policy)'
          )

          json_alerts = #{self}.alerts(
            zap_obj: 'required - zap_obj returned from #open method'
            target: 'required - base url to return alerts'
          )

          report_path = #{self}.generate_report(
            zap_obj: 'required - zap_obj returned from #open method',
            output_dir: 'required - directory to save report',
            report_type: 'required - <html|markdown|xml>'
          )

          #{self}.intercept(
            zap_obj: 'required - zap_obj returned from #open method',
            domain: 'required - FQDN to intercept (e.g. test.domain.local)',
            enabled: 'optional - boolean (defaults to true)'
          )

          watir_resp = #{self}.nonblocking_watir(
            browser_obj: 'required - browser_obj w/ browser_type: :firefox||:headless returned from #open method',
            instruction: 'required - watir instruction to make (e.g. button(text: \"Google Search\").click)'
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
