# frozen_string_literal: true

require 'socket'

module CSI
  module Plugins
    # This plugin was created to interact w/ Burp Suite Pro in headless mode to kick off spidering/live scanning
    # Be sure to build the latest version of burpbuddy:
    # https://github.com/tomsteele/burpbuddy/releases/latest
    # cp -a <latest_burpbuddy.jar> <path of burpsuite root>
    # ln -s <latest_burpbuddy.jar> <path of burpsuite root>/burpbuddy.jar
    module BurpSuite
      # Supported Method Parameters::
      # burp_obj = CSI::Plugins::BurpSuite.start(
      #   burp_jar_path: 'required - path of burp suite pro jar file',
      #   headless: 'optional - run burp headless if set to true',
      #   browser_type: 'optional - defaults to :firefox. See CSI::Plugins::TransparentBrowser.help for a list of types',
      # )

      @@logger = CSI::Plugins::CSILogger.create

      public_class_method def self.start(opts = {})
        burp_jar_path = opts[:burp_jar_path]
        raise 'Invalid path to burp jar file.  Please check your spelling and try again.' unless File.exist?(burp_jar_path)

        burp_root = File.dirname(burp_jar_path)

        browser_type = if opts[:browser_type].nil?
                         :firefox
                       else
                         opts[:browser_type]
                       end

        if opts[:headless]
          burp_cmd_string = "java -Xmx3G -Djava.awt.headless=true -classpath #{burp_root}/burpbuddy.jar:#{burp_jar_path} burp.StartBurp"
        else
          burp_cmd_string = "java -Xmx3G -classpath #{burp_root}/burpbuddy.jar:#{burp_jar_path} burp.StartBurp"
        end

        # Construct burp_obj
        burp_obj = {}
        burp_obj[:pid] = Process.spawn(burp_cmd_string)
        rest_browser = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)
        burp_obj[:mitm_proxy] = '127.0.0.1:8080'
        burp_obj[:burpbuddy_api] = '127.0.0.1:8001'
        burp_obj[:rest_browser] = rest_browser

        # Proxy always listens on localhost...use SSH tunneling if remote access is required
        burp_browser = CSI::Plugins::TransparentBrowser.open(
          browser_type: browser_type,
          proxy: "http://#{burp_obj[:mitm_proxy]}"
        )

        burp_obj[:burp_browser] = burp_browser

        # Wait for TCP 8001 to open prior to returning burp_obj
        loop do
          begin
            s = TCPSocket.new('127.0.0.1', 8001)
            s.close
            break
          rescue Errno::ECONNREFUSED
            print '.'
            sleep 3
            next
          end
        end

        return burp_obj
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.enable_proxy(
      #   burp_obj: 'required - burp_obj returned by #start method'
      # )

      public_class_method def self.enable_proxy(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]

        rest_browser.post("http://#{burpbuddy_api}/proxy/intercept/enable", nil)
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.disable_proxy(
      #   burp_obj: 'required - burp_obj returned by #start method'
      # )

      public_class_method def self.disable_proxy(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]

        rest_browser.post("http://#{burpbuddy_api}/proxy/intercept/disable", nil)
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # json_sitemap = CSI::Plugins::BurpSuite.get_current_sitemap(
      #   burp_obj: 'required - burp_obj returned by #start method'
      # )

      public_class_method def self.get_current_sitemap(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]

        sitemap = rest_browser.get("http://#{burpbuddy_api}/sitemap", content_type: 'application/json; charset=UTF8')
        json_sitemap = JSON.parse(sitemap)

        return json_sitemap
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # json_scan_queue = CSI::Plugins::BurpSuite.invoke_active_scan(
      #   burp_obj: 'required - burp_obj returned by #start method',
      #   target_url: 'required - target url to scan in sitemap (should be loaded & authenticated w/ burp_obj[:burp_browser])',
      #   use_https: 'optional - use SSL/TLS connection (defaults to true)'
      # )

      public_class_method def self.invoke_active_scan(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]
        target_url = opts[:target_url].to_s.scrub.strip.chomp
        # target_domain_name = URI.parse(target_url).host.split('.')[-2..-1].join('.')
        target_domain_name = URI.parse(target_url).host
        target_port = URI.parse(target_url).port.to_i
        if opts[:use_https] == false
          use_https = false
        else
          use_https = true
        end

        json_sitemap = get_current_sitemap(burp_obj: burp_obj)
        json_sitemap['data'].each do |site|
          json_req = site['request']
          json_host = json_req['host'].to_s.scrub.strip.chomp
          json_port = json_req['port'].to_i
          json_uri = "#{json_req['url'].to_s.scrub.strip.chomp('/')}#{json_req['path'].to_s.scrub.strip.chomp}"

          next unless json_host == target_domain_name && json_port == target_port
          puts "Adding #{json_uri} to Active Scan"
          post_body = "{ \"host\": \"#{json_host}\", \"port\": \"#{json_port}\", \"useHttps\": #{use_https}, \"request\": \"#{site['request']['raw']}\" }"
          # Kick off an active scan for each given page in the json_sitemap results
          rest_browser.post("http://#{burpbuddy_api}/scan/active", post_body, content_type: 'application/json')
        end

        # Wait for scan completion
        scan_queue = rest_browser.get("http://#{burpbuddy_api}/scan/active")
        json_scan_queue = JSON.parse(scan_queue)
        scan_queue_total = json_scan_queue['data'].count
        json_scan_queue['data'].each do |scan_item|
          until scan_item['percentComplete'] == 100
            percent = scan_item['percentComplete']
            this_scan_item_id = scan_item['id']
            scan_item_resp = rest_browser.get("http://#{burpbuddy_api}/scan/active/#{this_scan_item_id}")
            scan_item = JSON.parse(scan_item_resp)
            print "Target ID ##{this_scan_item_id} of ##{scan_queue_total}| #{format('%-3.3s', percent)}% complete"
            print "\r"
            sleep 1
          end
          puts "\n"
        end

        scan_queue = rest_browser.get("http://#{burpbuddy_api}/scan/active")
        json_scan_queue = JSON.parse(scan_queue)
        json_scan_queue['data'].each do |scan_item|
          this_scan_item_id = scan_item['id']
          puts "Target ID ##{this_scan_item_id} of ##{scan_queue_total} | #{scan_item['percentComplete']}% complete"
        end

        return json_scan_queue # Return last status of all items in scan queue (should all say 100% complete)
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # json_scan_issues = CSI::Plugins::BurpSuite.get_scan_issues(
      #   burp_obj: 'required - burp_obj returned by #start method'
      # )

      public_class_method def self.get_scan_issues(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]

        scan_issues = rest_browser.get("http://#{burpbuddy_api}/scanissues")
        json_scan_issues = JSON.parse(scan_issues)

        return json_scan_issues
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.generate_scan_report(
      #   burp_obj: 'required - burp_obj returned by #start method',
      #   report_type: :html|:xml,
      #   output_path: 'required - path to save report results'
      # )

      public_class_method def self.generate_scan_report(opts = {})
        burp_obj = opts[:burp_obj]
        rest_browser = burp_obj[:rest_browser]
        burpbuddy_api = burp_obj[:burpbuddy_api]
        report_type = opts[:report_type]
        raise 'INVALID Report Type' unless report_type == :html || report_type == :xml
        output_path = opts[:output_path].to_s.scrub

        post_body = "{ \"report_type\": \"#{report_type.to_s.upcase}\", \"output_path\": \"#{output_path}\" }"
        rest_browser.post("http://#{burpbuddy_api}/generate_scan_report", post_body, content_type: 'application/json')
      rescue => e
        stop(burp_obj: burp_obj) unless burp_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.update_burp_jar(
      # )

      public_class_method def self.update_burp_jar
        # TODO: Do this.
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.stop(
      #   burp_obj: 'required - burp_obj returned by #start method'
      # )

      public_class_method def self.stop(opts = {})
        burp_obj = opts[:burp_obj]
        burp_browser = burp_obj[:burp_browser]
        burp_pid = burp_obj[:pid]

        burp_browser = CSI::Plugins::TransparentBrowser.close(browser_obj: burp_browser)
        Process.kill('TERM', burp_pid)

        burp_obj = nil
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          burp_obj = #{self}.start(
            burp_jar_path: 'required - path of burp suite pro jar file',
            headless: 'optional - run headless if set to true',
            browser_type: 'optional - defaults to :firefox. See CSI::Plugins::TransparentBrowser.help for a list of types',
          )

          #{self}.enable_proxy(
            burp_obj: 'required - burp_obj returned by #start method'
          )

          #{self}.disable_proxy(
            burp_obj: 'required - burp_obj returned by #start method'
          )

          json_sitemap = #{self}.get_current_sitemap(
            burp_obj: 'required - burp_obj returned by #start method'
          )

          json_scan_queue = #{self}.invoke_active_scan(
            burp_obj: 'required - burp_obj returned by #start method',
            target_url: 'required - target url to scan in sitemap (should be loaded & authenticated w/ burp_obj[:burp_browser])',
            use_https: 'optional - use SSL/TLS connection (defaults to true)'
          )

          json_scan_issues = #{self}.get_scan_issues(
            burp_obj: 'required - burp_obj returned by #start method'
          ).to_json

          #{self}.generate_scan_report(
            burp_obj: 'required - burp_obj returned by #start method',
            report_type: :html|:xml,
            output_path: 'required - path to save report results'
          )

          #{self}.stop(
            burp_obj: 'required - burp_obj returned by #start method'
          )

          #{self}.authors
        "
      end
    end
  end
end
