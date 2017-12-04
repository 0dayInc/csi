# frozen_string_literal: true

require 'watir'
require 'rest-client'
require 'socksify'

module CSI
  module Plugins
    # This plugin rocks. Chrome, Firefox, PhantomJS, IE, REST Client,
    # all from the comfort of one plugin.  Proxy support (e.g. Burp
    # Suite Professional) is completely available for all browsers
    # except for limited functionality within IE (IE has interesting
    # protections in place to prevent this).  This plugin also supports
    # taking screenshots :)
    module TransparentBrowser
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # browser_obj = CSI::Plugins::TransparentBrowser.open(
      #   browser_type: :firefox|:chrome|:headless|:rest,
      #   proxy: 'optional - scheme://proxy_host:port',
      #   with_tor: 'optional - boolean (defaults to false)'
      # )

      public

      def self.open(opts = {})
        this_browser = nil
        browser_type = opts[:browser_type]
        proxy = opts[:proxy].to_s unless opts[:proxy].nil?
        with_tor = if opts[:with_tor]
                     true
                   else
                     false
                   end

        # Let's crank up the default timeout from 30 seconds to 15 min for slow sites
        Watir.default_timeout = 900

        case browser_type
        when :firefox
          this_profile = Selenium::WebDriver::Firefox::Profile.new
          this_profile.native_events = false
          this_profile.proxy = Selenium::WebDriver::Proxy.new(no_proxy: true)

          if proxy
            if with_tor
              this_profile['javascript.enabled'] = false
              this_profile.proxy = Selenium::WebDriver::Proxy.new(
                socks: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            else
              this_profile.proxy = Selenium::WebDriver::Proxy.new(
                http: "#{URI(proxy).host}:#{URI(proxy).port}",
                ssl: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            end
          end

          this_browser = Watir::Browser.new(
            :firefox,
            profile: this_profile
          )

        when :chrome
          this_profile = Selenium::WebDriver::Chrome::Profile.new
          this_profile['download.prompt_for_download'] = false
          this_profile['download.default_directory'] = '~/Downloads'

          if proxy
            if with_tor
              this_browser = Watir::Browser.new(
                :chrome,
                switches: [
                  "--proxy-server=#{proxy}",
                  "--host-resolver-rules='MAP * 0.0.0.0 , EXCLUDE #{URI(proxy).host}'"
                ]
              )
            else
              this_browser = Watir::Browser.new(
                :chrome,
                switches: ["--proxy-server=#{proxy}"]
              )
            end
          else
            this_browser = Watir::Browser.new(:chrome)
          end

        when :headless
          # Soon Selenium will Deprecate PhantomJS...when they do, we'll be ready.
          # This hasn't been transitioned yet because we're waiting for the
          # chromedriver team to sort out headless w/ accepting insecure TLS and --proxy-server when combined
          # which currently results in the browser to refuse to display a webpage and/or hang.

          # this_profile = Selenium::WebDriver::Chrome::Profile.new
          # this_profile['download.prompt_for_download'] = false
          # this_profile['download.default_directory'] = '~/Downloads'

          if proxy
            if with_tor
              this_browser = Watir::Browser.new(
                :chrome,
                headless: true,
                switches: [
                  "--proxy-server=#{proxy}",
                  "--host-resolver-rules='MAP * 0.0.0.0 , EXCLUDE #{URI(proxy).host}'"
                ]
              )
            else
              this_browser = Watir::Browser.new(
                :chrome,
                headless: true,
                switches: [
                  "--proxy-server=#{proxy}"
                ]
              )
            end
          else
            this_browser = Watir::Browser.new(
              :chrome,
              headless: true
            )
          end

          # if proxy
          #   if with_tor
          #     args = [
          #       '--proxy-type=socks5',
          #       "--proxy=#{URI(proxy).host}:#{URI(proxy).port}",
          #       '--ignore-ssl-errors=true',
          #       '--ssl-protocol=any',
          #       '--web-security=false'
          #     ]
          #   else
          #     args = [
          #       "--proxy=#{URI(proxy).host}:#{URI(proxy).port}",
          #       '--ignore-ssl-errors=true',
          #       '--ssl-protocol=any',
          #       '--web-security=false'
          #     ]
          #   end
          # else
          #   args = [
          #     '--ignore-ssl-errors=true',
          #     '--ssl-protocol=any',
          #     '--web-security=false'
          #   ]
          # end

          # this_browser = Watir::Browser.new(
          #   :phantomjs,
          #   driver_opts: { args: args }
          # )

        when :rest
          this_browser = RestClient
          if proxy
            if with_tor
              TCPSocket.socks_server = URI(proxy).host
              TCPSocket.socks_port = URI(proxy).port
            else
              this_browser.proxy = proxy
            end
          end

        else
          puts 'Error: browser_type only supports :firefox, :chrome, :headless, or :rest'
          return nil
        end

        return this_browser
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # browser_obj = CSI::Plugins::TransparentBrowser.linkout(
      #   browser_obj: browser_obj1
      # )

      public

      def self.linkout(opts = {})
        this_browser_obj = opts[:browser_obj]

        this_browser_obj.links.each do |link|
          @@logger.info("#{link.text} => #{link.href}\n\n\n") unless link.text == ''
        end

        return this_browser_obj
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::TransparentBrowser.type_as_human(
      #   q: 'required - query string to randomize',
      #   rand_sleep_float: 'optional - float timing in between keypress (defaults to 0.09)'
      # )

      public

      def self.type_as_human(opts = {})
        query_string = opts[:q].to_s

        rand_sleep_float = if opts[:rand_sleep_float]
                             opts[:rand_sleep_float].to_f
                           else
                             0.09
                           end

        query_string.each_char do |char|
          yield char
          sleep Random.rand(rand_sleep_float)
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # browser_obj = CSI::Plugins::TransparentBrowser.close(
      #   :browser_obj => browser_obj1
      # )

      public

      def self.close(opts = {})
        this_browser_obj = opts[:browser_obj]

        unless this_browser_obj.to_s.include?('RestClient')
          this_browser_obj.close
        end
        this_browser_obj = nil

        return this_browser_obj
      rescue => e
        puts e.message
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
        puts %{USAGE:
          browser_obj1 = #{self}.open(
            browser_type: :firefox|:chrome|:headless|:rest,
            proxy: 'optional scheme://proxy_host:port',
            with_tor: 'optional boolean (defaults to false)'
          )
          puts "browser_obj1.public_methods"

          browser_obj1 = #{self}.linkout(browser_obj: browser_obj1)

          #{self}.type_as_human(
            q: 'required - query string to randomize',
            rand_sleep_float: 'optional - float timing in between keypress (defaults to 0.09)'
          ) {|char| browser_obj1.text_field(name: "q").send_keys(char) }

          browser_obj1 = #{self}.close(browser_obj: browser_obj1)

          #{self}.authors
        }
      end
    end
  end
end
