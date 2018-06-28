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
      # browser_obj1 = CSI::Plugins::TransparentBrowser.open(
      #   browser_type: :firefox|:chrome|:headless|:rest,
      #   proxy: 'optional - scheme://proxy_host:port',
      #   with_tor: 'optional - boolean (defaults to false)'
      # )

      public

      def self.open(opts = {})
        this_browser = nil
        browser_type = opts[:browser_type]
        proxy = opts[:proxy].to_s unless opts[:proxy].nil?
        opts[:with_tor] ? (with_tor = true) : (with_tor = false)

        # Let's crank up the default timeout from 30 seconds to 15 min for slow sites
        Watir.default_timeout = 900

        case browser_type
        when :firefox
          this_profile = Selenium::WebDriver::Firefox::Profile.new
          # Downloads reside in ~/Downloads
          this_profile['browser.download.folderList'] = 1
          this_profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/pdf'

          # disable Firefox's built-in PDF viewer
          this_profile['pdfjs.disabled'] = true

          # disable Adobe Acrobat PDF preview plugin
          this_profile['plugin.scan.plid.all'] = false
          this_profile['plugin.scan.Acrobat'] = '99.0'

          # ensure localhost proxy capabilities are enabled
          this_profile['network.proxy.no_proxies_on'] = ''

          caps = Selenium::WebDriver::Remote::Capabilities.firefox
          caps[:acceptInsecureCerts] = true

          if proxy
            this_profile['network.proxy.type'] = 1
            if with_tor
              this_profile['network.proxy.socks_version'] = 5
              this_profile['network.proxy.socks'] = URI(proxy).host
              this_profile['network.proxy.socks_port'] = URI(proxy).port
            else
              this_profile['network.proxy.ftp'] = URI(proxy).host
              this_profile['network.proxy.ftp_port'] = URI(proxy).port
              this_profile['network.proxy.http'] = URI(proxy).host
              this_profile['network.proxy.http_port'] = URI(proxy).port
              this_profile['network.proxy.ssl'] = URI(proxy).host
              this_profile['network.proxy.ssl_port'] = URI(proxy).port
            end
          end

          options = Selenium::WebDriver::Firefox::Options.new
          options.profile = this_profile
          driver = Selenium::WebDriver.for(:firefox, options: options, desired_capabilities: caps)
          this_browser = Watir::Browser.new(driver)

        when :chrome
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
          this_profile = Selenium::WebDriver::Firefox::Profile.new
          # Downloads reside in ~/Downloads
          this_profile['browser.download.folderList'] = 1
          this_profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/pdf'

          # disable Firefox's built-in PDF viewer
          this_profile['pdfjs.disabled'] = true

          # disable Adobe Acrobat PDF preview plugin
          this_profile['plugin.scan.plid.all'] = false
          this_profile['plugin.scan.Acrobat'] = '99.0'

          # ensure localhost proxy capabilities are enabled
          this_profile['network.proxy.no_proxies_on'] = ''

          caps = Selenium::WebDriver::Remote::Capabilities.firefox
          caps[:acceptInsecureCerts] = true

          if proxy
            this_profile['network.proxy.type'] = 1
            if with_tor
              this_profile['network.proxy.socks_version'] = 5
              this_profile['network.proxy.socks'] = URI(proxy).host
              this_profile['network.proxy.socks_port'] = URI(proxy).port
            else
              this_profile['network.proxy.ftp'] = URI(proxy).host
              this_profile['network.proxy.ftp_port'] = URI(proxy).port
              this_profile['network.proxy.http'] = URI(proxy).host
              this_profile['network.proxy.http_port'] = URI(proxy).port
              this_profile['network.proxy.ssl'] = URI(proxy).host
              this_profile['network.proxy.ssl_port'] = URI(proxy).port
            end
          end

          options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
          options.profile = this_profile
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
        raise e
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
        raise e
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
        raise e
      end

      # Supported Method Parameters::
      # browser_obj1 = CSI::Plugins::TransparentBrowser.close(
      #   browser_obj: 'required - browser_obj returned from #open method)'
      # )

      public

      def self.close(opts = {})
        this_browser_obj = opts[:browser_obj]

        unless this_browser_obj.to_s.include?('RestClient')
          # Close the browser unless this_browser_obj.nil? (thus the &)
          this_browser_obj&.close
        end
        this_browser_obj = nil

        return this_browser_obj
      rescue => e
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
          browser_obj1 = #{self}.open(
            browser_type: :firefox|:chrome|:headless|:rest,
            proxy: 'optional scheme://proxy_host:port',
            with_tor: 'optional boolean (defaults to false)'
          )
          puts "browser_obj1.public_methods"

          browser_obj1 = #{self}.linkout(
            browser_obj: 'required - browser_obj returned from #open method)'
          )

          #{self}.type_as_human(
            q: 'required - query string to randomize',
            rand_sleep_float: 'optional - float timing in between keypress (defaults to 0.09)'
          ) {|char| browser_obj1.text_field(name: "q").send_keys(char) }

          browser_obj1 = #{self}.close(
            browser_obj: 'required - browser_obj returned from #open method)'
          )

          #{self}.authors
        "
      end
    end
  end
end
