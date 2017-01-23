# frozen_string_literal: true
module CSI
  module WWW
    # This plugin supports Duckduckgo actions.
    module Duckduckgo
      # Supported Method Parameters::
      # CSI::WWW::Duckduckgo.open(
      #   browser_type: :firefox|:chrome|:ie|:headless|:rest,
      #   proxy: 'optional http(s)://proxy_host:port',
      #   with_tor: 'optional boolean (defaults to false)'
      # )

      @@logger = CSI::Plugins::CSILogger.create

      public

      def self.open(opts = {})
        if $browser
          @@logger.info('leveraging existing $browser object...')
          @@logger.info("run #{self}.close to end session.")
        else
          browser_type = if opts[:browser_type].nil?
                           :firefox
                         else
                           opts[:browser_type]
                         end

          proxy = opts[:proxy].to_s unless opts[:proxy].nil?

          with_tor = if opts[:with_tor]
                       true
                     else
                       false
                     end

          @@logger.info('instantiating new $browser object...')
          @@logger.info('run $browser.close to end session.')
          if proxy
            if with_tor
              $browser = CSI::Plugins::TransparentBrowser.open(
                browser_type: browser_type,
                proxy: proxy,
                with_tor: true
              )
            else
              $browser = CSI::Plugins::TransparentBrowser.open(
                browser_type: browser_type,
                proxy: proxy
              )
            end
          else
            $browser = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type
            )
          end
        end

        if $browser
          $browser.goto('https://duckduckgo.com')
          CSI::Plugins::TransparentBrowser.linkout(browser_obj: $browser)
        end

      rescue => e
        puts "Error: #{e.message}"
        return nil
      end

      # Supported Method Parameters::
      # CSI::WWW::Duckduckgo.search(
      #   q: 'required search string'
      # )

      public

      def self.search(opts = {})
        q = opts[:q].to_s

        if $browser
          $browser.text_field(name: 'q').when_present.set(q)
          if $browser.url == 'https://duckduckgo.com/' || $browser.url == 'http://3g2upl4pq6kufc4m.onion/'
            $browser.button(id: 'search_button_homepage').when_present.click
          else
            $browser.button(id: 'search_button').when_present.click
          end
          sleep 3 # Cough: <hack>
          CSI::Plugins::TransparentBrowser.linkout(browser_obj: $browser)
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Duckduckgo.onion

      public

      def self.onion
        puts "Be sure the $browser object has the following parameters set:

          #{self}.open(
            browser_type: :chrome,
            proxy: 'socks5://127.0.0.1:9050',
            with_tor: true
          )
        "
        $browser&.goto('http://3g2upl4pq6kufc4m.onion')
      end

      # Supported Method Parameters::
      # CSI::WWW::Duckduckgo.close

      public

      def self.close
        $browser = CSI::Plugins::TransparentBrowser.close(browser_obj: $browser)
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
          #{self}.open(
            browser_type: 'optional :firefox|:chrome|:ie|:headless|:rest (Defaults to :firefox)',
            proxy: 'optional http(s)://proxy_host:port',
            with_tor: 'optional boolean (defaults to false)'
          )
          puts "$browser.public_methods"

          #{self}.search(
            q: 'required search string'
          )

          #{self}.onion

          #{self}.close

          #{self}.authors
        }
      end
    end
  end
end
