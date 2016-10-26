module CSI
  module Plugins
    # This plugin was created to interact w/ Burp Suite Pro in headless mode to kick off spidering/live scanning
    # Different services listen on random epheral ports and lo interfaces (127.0.0.1-127.0.0.4) so that
    # we can scan multiple targets in parallel and using lsof determine which random ports we should be
    # communicating w/ for a given session.  Please note, in OSX you'll need to reference 127.0.0.2-127.0.0.4
    # as an alias to localhost:
    # sudo ifconfig lo0 alias 127.0.0.2 up
    # sudo ifconfig lo0 alias 127.0.0.3 up
    # sudo ifconfig lo0 alias 127.0.0.4 up
    # In Ubuntu, add the following to /etc/rc.local:
    # ifconfig lo:0 127.0.0.2 netmask 255.0.0.0 up
    # ifconfig lo:1 127.0.0.3 netmask 255.0.0.0 up
    # ifconfig lo:2 127.0.0.4 netmask 255.0.0.0 up
    # Otherwise the API won't be able to bind to the necessary ephermal ports
    # Next, be sure to build the forked version of burpbuddy:
    # cp -a <path of csi root>/third_party/burpbuddy <path of burpsuite root>
    # cd <path of burpsuite root>/burpbuddy/burp && mvn package
    # Assuming the build succeeds, copy the burpbuddy jar to your burpsuite root:
    # cp <path of burpsuite root>/burpbuddy/burp/target/burpbuddy-2.3.1.jar <path of burpsuite root>/
    # Lastly, you may need to enable setuid on the lsof command if you're running as a non-priv user:
    # $ sudo chmod u+s /usr/bin/lsof 
    # Also, please note - To date this plugin only supports targets that are DNS domains...no ip targets supported yet.
    module BurpSuite
      # Supported Method Parameters::
      # burp_obj = CSI::Plugins::BurpSuite.start(
      #   :burp_jar_path => 'required - path of burp suite pro jar file',
      #   :headless => 'optional - run burp headless if set to true',
      #   :browser_type => 'optional - defaults to :firefox. See CSI::Plugins::TransparentBrowser.help for a list of types'
      # )

      @@logger = CSI::Plugins::CSILogger.create()

      public
      def self.start(opts = {})
        begin
          burp_jar_path = opts[:burp_jar_path]
          raise "Invalid path to burp jar file.  Please check your spelling and try again." unless File.exists?(burp_jar_path)

          burp_root = File.dirname(burp_jar_path)

          if opts[:browser_type].nil?
            browser_type = :firefox
          else
            browser_type = opts[:browser_type]
          end

          if opts[:headless]
            #burp_cmd_string = "java -Djava.awt.headless=true -classpath #{burp_root}/CSIBurpExtender.jar:#{burp_jar_path} burp.StartBurp"
            burp_cmd_string = "java -Djava.awt.headless=true -classpath #{burp_root}/burpbuddy-2.3.1.jar:#{burp_jar_path} burp.StartBurp"
          else
            #burp_cmd_string = "java -classpath #{burp_root}/CSIBurpExtender.jar:#{burp_jar_path} burp.StartBurp"
            burp_cmd_string = "java -classpath #{burp_root}/burpbuddy-2.3.1.jar:#{burp_jar_path} burp.StartBurp"
          end

          burp_obj = {}
          burp_obj[:pid] = Process.spawn(burp_cmd_string)
        
          # Wait until burp has completed initialized into a ready state 
          lsof_cmd = "lsof -nP -p #{burp_obj[:pid]} | grep LISTEN"
          lsof_res = []
          while lsof_res.count < 3
            sleep 1
            lsof_res = `#{lsof_cmd}`.split("\n")
            #@@logger.info(lsof_res) # Debugging
          end
   
          # Now assign our ephemeral ports to the proper burp_obj keys
          lsof_res.each do |localhost_alias|
            this_localhost = localhost_alias.strip.chomp.split("\s")[-2].split(":")[0]
            this_port = localhost_alias.strip.chomp.split("\s")[-2].split(":")[-1]
            case this_localhost
              when "127.0.0.1"
                burp_obj[:proxy_port] = "#{this_localhost}:#{this_port}"
              when "127.0.0.2"
                burp_obj[:cmd_ctl_port] = "#{this_localhost}:#{this_port}"
              when "127.0.0.3"
                burp_obj[:web_socket_port] = "#{this_localhost}:#{this_port}"
              when "127.0.0.4"
                burp_obj[:request_response_port] = "#{this_localhost}:#{this_port}"
            else
              raise %(Proxy/API/WebSocket FAILURE:
                      Invalid localhost reference #{this_localhost}
                      did the command:
                      #{lsof_cmd}
                      change its response output?"
                    )
            end
          end

          cmd_ctl_browser = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest)
          burp_obj[:cmd_ctl_browser] = cmd_ctl_browser

          # Proxy always listens on localhost...use SSH tunneling if remote access is required
          burp_browser = CSI::Plugins::TransparentBrowser.open(
            :browser_type => browser_type,
            :proxy => "http://#{burp_obj[:proxy_port]}"
          )
          burp_obj[:burp_browser] = burp_browser

          return burp_obj
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.enable_proxy(
      #   :burp_obj => 'required - burp_obj returned by #start method'
      # )
      public
      def self.enable_proxy(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]

          cmd_ctl_browser.post("http://#{burp_cmd_ctl_port}/proxy/intercept/enable", nil)
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.disable_proxy(
      #   :burp_obj => 'required - burp_obj returned by #start method'
      # )
      public
      def self.disable_proxy(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]
    
          cmd_ctl_browser.post("http://#{burp_cmd_ctl_port}/proxy/intercept/disable", nil)
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # json_sitemap = CSI::Plugins::BurpSuite.get_current_sitemap(
      #   :burp_obj => 'required - burp_obj returned by #start method'
      # )
      public
      def self.get_current_sitemap(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]
  
          sitemap = cmd_ctl_browser.get("http://#{burp_cmd_ctl_port}/sitemap", {:content_type => 'application/json; charset=UTF8'})
          json_sitemap = JSON.parse(sitemap)
 
          return json_sitemap
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # json_scan_queue = CSI::Plugins::BurpSuite.invoke_active_scan(
      #   :burp_obj => 'required - burp_obj returned by #start method',
      #   :target_url => 'required - target url to scan in sitemap (should be loaded & authenticated w/ burp_obj[:burp_browser])'
      # )
      public
      def self.invoke_active_scan(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]
          target_url = opts[:target_url].to_s.scrub
          target_domain_name = URI(target_url).host.split(".")[-2..-1].join(".")
      
          json_sitemap = self.get_current_sitemap(:burp_obj => burp_obj)
          json_sitemap["data"].each do |site|
            if site['request']['host'] =~ /#{target_domain_name}/ # Accepts DNS name only - no IPs
              puts "Adding #{site['request']['host']} to Active Scan";
              if site['request']['port'].to_i == 443
                bool_ssl = true
              else
                bool_ssl = false
              end
              post_body = "{ \"host\": \"#{site['request']['host']}\", \"port\": \"#{site['request']['port']}\", \"useHttps\": #{bool_ssl}, \"request\": \"#{site['request']['raw']}\" }"
              # Kick off an active scan for each given page in the json_sitemap results
              cmd_ctl_browser.post("http://#{burp_cmd_ctl_port}/scan/active", post_body, :content_type => 'application/json');
            end
          end

          # Wait for scan completion
          scan_queue = cmd_ctl_browser.get("http://#{burp_cmd_ctl_port}/scan/active")
          json_scan_queue = JSON.parse(scan_queue)
          scan_queue_total = json_scan_queue["data"].count
          json_scan_queue["data"].each do |scan_item|
            until scan_item["percentComplete"] == 100
              this_scan_item_id = scan_item["id"]
              scan_item_resp = cmd_ctl_browser.get("http://#{burp_cmd_ctl_port}/scan/active/#{this_scan_item_id}")
              scan_item = JSON.parse(scan_item_resp)
              puts "Target ID ##{this_scan_item_id} of ##{scan_queue_total}| #{scan_item["percentComplete"]}% complete"
              sleep 1
            end
            puts "\n"
          end

          scan_queue = cmd_ctl_browser.get("http://#{burp_cmd_ctl_port}/scan/active")
          json_scan_queue = JSON.parse(scan_queue)
          json_scan_queue["data"].each do |scan_item|
            this_scan_item_id = scan_item["id"]
            puts "Target ID ##{this_scan_item_id} of ##{scan_queue_total} | #{scan_item["percentComplete"]}% complete"
          end

          return json_scan_queue # Return last status of all items in scan queue (should all say 100% complete)
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # json_scan_issues = CSI::Plugins::BurpSuite.get_scan_issues(
      #   :burp_obj => 'required - burp_obj returned by #start method'
      # )
      public
      def self.get_scan_issues(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]
  
          scan_issues = cmd_ctl_browser.get("http://#{burp_cmd_ctl_port}/scanissues")
          json_scan_issues = JSON.parse(scan_issues)

          return json_scan_issues
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.generate_scan_report(
      #   :burp_obj => 'required - burp_obj returned by #start method',
      #   :report_type => :html|:xml,
      #   :output_path => 'required - path to save report results'
      # )
      public
      def self.generate_scan_report(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]
          report_type = opts[:report_type]
          raise "INVALID Report Type" unless report_type == :html || report_type == :xml
          output_path = opts[:output_path].to_s.scrub

          post_body = "{ \"report_type\": \"#{report_type.to_s.upcase}\", \"output_path\": \"#{output_path}\" }"
          cmd_ctl_browser.post("http://#{burp_cmd_ctl_port}/generate_scan_report", post_body, :content_type => 'application/json');
        rescue => e
          raise e.message
          self.stop(:burp_obj => burp_obj) unless burp_obj.nil?
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.update_burp_jar(
      # )
      public
      def self.update_burp_jar(opts = {})
        # TODO: Do this.
      end

      # Supported Method Parameters::
      # CSI::Plugins::BurpSuite.stop(
      #   :burp_obj => 'required - burp_obj returned by #start method'
      # )
      public
      def self.stop(opts = {})
        begin
          burp_obj = opts[:burp_obj]
          burp_browser = burp_obj[:burp_browser]
          cmd_ctl_browser = burp_obj[:cmd_ctl_browser]
          burp_cmd_ctl_port = burp_obj[:cmd_ctl_port]

          burp_browser.close unless burp_browser.nil?
          cmd_ctl_browser.post("http://#{burp_cmd_ctl_port}/shutdown_session", nil);
        rescue => e
          raise e
        ensure
          Process.kill("TERM", burp_obj[:pid])
          Process.wait
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
          burp_obj = #{self}.start(
            :burp_jar_path => 'required - path of burp suite pro jar file',
            :headless => 'optional - run headless if set to true',
            :browser_type => 'optional - defaults to :firefox. See CSI::Plugins::TransparentBrowser.help for a list of types'
          )

          #{self}.enable_proxy(
            :burp_obj => 'required - burp_obj returned by #start method'
          )

          #{self}.disable_proxy(
            :burp_obj => 'required - burp_obj returned by #start method'
          )

          json_sitemap = #{self}.get_current_sitemap(
            :burp_obj => 'required - burp_obj returned by #start method'
          )

          json_scan_queue = #{self}.invoke_active_scan(
            :burp_obj => 'required - burp_obj returned by #start method',
            :target_url => 'required - target url to scan in sitemap (should be loaded & authenticated w/ burp_obj[:burp_browser])'
          )

          json_scan_issues = #{self}.get_scan_issues(
            :burp_obj => 'required - burp_obj returned by #start method'
          )

          #{self}.generate_scan_report(
            :burp_obj => 'required - burp_obj returned by #start method',
            :report_type => :html|:xml,
            :output_path => 'required - path to save report results'
          )

          #{self}.stop(
            :burp_obj => 'required - burp_obj returned by #start method'
          )

          #{self}.authors
        }
      end
    end
  end
end
