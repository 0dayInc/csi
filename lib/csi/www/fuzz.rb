# frozen_string_literal: true
module CSI
  module WWW
    # This plugin supports Fuzz actions.
    module Fuzz
      # Supported Method Parameters::
      # CSI::WWW::Fuzz.open(
      #   target_url: 'required - target url to fuzz',
      #   browser_type: :firefox|:chrome|:ie|:headless|:rest,
      #   proxy: 'optional http(s)://proxy_host:port',
      #   with_tor: 'optional boolean (defaults to false)',
      #   with_zap: 'optional boolean (defaults to false)'
      # )

      @@logger = CSI::Plugins::CSILogger.create

      public

      def self.open(opts = {})
        if $browser
          @@logger.info('leveraging existing $browser object...')
          @@logger.info("run #{self}.close to end session.")
        else
          target_url = opts[:target_url].to_s

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

          with_zap = if opts[:with_zap]
                       proxy = 'http://127.0.0.1:8080' unless proxy
                       $zap_obj = CSI::Plugins::OwaspZapIt.start(
                         target: target_url,
                         proxy: proxy
                       )
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
                with_tor: with_tor
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
          $browser.goto(target_url)
          CSI::Plugins::TransparentBrowser.linkout(browser_obj: $browser)
        end

      rescue => e
        puts "Error: #{e.message}"
        return nil
      end

      # Supported Method Parameters::
      # CSI::WWW::Fuzz.close

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
            target_url: 'required - target url to fuzz',
            browser_type: 'optional :firefox|:chrome|:ie|:headless|:rest (Defaults to :firefox)',
            proxy: 'optional http(s)://proxy_host:port',
            with_tor: 'optional boolean (defaults to false)',
            with_zap: 'optional boolean (defaults to false)'
          )
          puts "$browser.public_methods"

          #{self}.fuzzdb(
            attack_patterns: 'required - array of fuzzdb attack patterns',
            watir_target: 'required - watir object to target with fuzzdb'
          )

          #{self}.close

          #{self}.authors
        }
      end
    end
  end
end
