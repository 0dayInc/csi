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
          caps = Selenium::WebDriver::Remote::Capabilities.firefox
          caps[:acceptInsecureCerts] = true

          if proxy
            if with_tor
              # BUG: Setting SOCKS Proxy doesn't work
              # Selenium::WebDriver::Error::SessionNotCreatedError:
              # InvalidArgumentError: Expected [object Undefined] undefined to be an integer
              # from WebDriverError@chrome://marionette/content/error.js:235:5

              caps[:javascript_enabled] = false
              caps[:proxy] = Selenium::WebDriver::Proxy.new(
                socks: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            else
              caps[:proxy] = Selenium::WebDriver::Proxy.new(
                http: "#{URI(proxy).host}:#{URI(proxy).port}",
                ssl: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            end
          end

          driver = Selenium::WebDriver.for(:firefox, desired_capabilities: caps)
          this_browser = Watir::Browser.new(driver)

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
          caps = Selenium::WebDriver::Remote::Capabilities.firefox
          caps[:acceptInsecureCerts] = true

          if proxy
            if with_tor
              # BUG: Setting SOCKS Proxy doesn't work
              # Selenium::WebDriver::Error::SessionNotCreatedError:
              # InvalidArgumentError: Expected [object Undefined] undefined to be an integer
              # from WebDriverError@chrome://marionette/content/error.js:235:5

              caps[:javascript_enabled] = false
              caps[:proxy] = Selenium::WebDriver::Proxy.new(
                socks: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            else
              caps[:proxy] = Selenium::WebDriver::Proxy.new(
                http: "#{URI(proxy).host}:#{URI(proxy).port}",
                ssl: "#{URI(proxy).host}:#{URI(proxy).port}"
              )
            end
          end

          options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
          driver = Selenium::WebDriver.for(:firefox, options: options, desired_capabilities: caps)
          this_browser = Watir::Browser.new(driver)

          # Chrome headless
          # this_profile = Selenium::WebDriver::Chrome::Profile.new
          # this_profile['download.prompt_for_download'] = false
          # this_profile['download.default_directory'] = '~/Downloads'

          # if proxy
          #   if with_tor
          #     this_browser = Watir::Browser.new(
          #       :chrome,
          #       headless: true,
          #       switches: [
          #         "--proxy-server=#{proxy}",
          #         "--host-resolver-rules='MAP * 0.0.0.0 , EXCLUDE #{URI(proxy).host}'"
          #       ]
          #     )
          #   else
          #     this_browser = Watir::Browser.new(
          #       :chrome,
          #       headless: true,
          #       switches: [
          #         "--proxy-server=#{proxy}"
          #       ]
          #     )
          #   end
          # else
          #   this_browser = Watir::Browser.new(
          #     :chrome,
          #     headless: true
          #   )
          # end

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
