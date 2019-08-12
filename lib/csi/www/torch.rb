# frozen_string_literal: true

module CSI
  module WWW
    # This plugin supports Torch (Tor Search Engine) actions.
    module Torch
      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Torch.open(
      #   browser_type: 'optional - :firefox|:chrome|:ie|:headless (Defaults to :firefox)',
      #   proxy: 'optional - scheme://proxy_host:port',
      #   with_tor: 'optional - boolean (defaults to false)'
      # )

      public_class_method def self.open(opts = {})
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

        with_tor = if opts[:with_tor].nil?
                     true
                   else
                     false
                   end

        if proxy
          if with_tor
            browser_obj = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type,
              proxy: proxy,
              with_tor: true
            )
          else
            browser_obj = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type,
              proxy: proxy
            )
          end
        else
          browser_obj = CSI::Plugins::TransparentBrowser.open(
            browser_type: browser_type
          )
        end
        browser_obj.goto('http://www.torchtorsearch.com')

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Torch.open(
      #   browser_obj: 'required - browser_obj returned from #open method',
      #   q: 'required search string'
      # )

      public_class_method def self.search(opts = {})
        browser_obj = opts[:browser_obj]
        q = opts[:q].to_s

        browser_obj.text_field(name: 'q').wait_until(&:present?).set(q)
        browser_obj.button(name: 'cmd').wait_until(&:present?).click

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Torch.onion(
      #   browser_obj: 'required - browser_obj returned from #open method'
      # )

      public_class_method def self.onion
        browser_obj = opts[:browser_obj]
        browser_obj.goto('http://xmh57jrzrnw6insl.onion')

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Torch.close(
      #   browser_obj: 'required - browser_obj returned from #open method'
      # )

      public_class_method def self.close(opts = {})
        browser_obj = opts[:browser_obj]
        browser_obj = CSI::Plugins::TransparentBrowser.close(browser_obj: browser_obj)
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
        puts %{USAGE:
          browser_obj = #{self}.open(
            browser_type: 'optional :firefox|:chrome|:ie|:headless (Defaults to :firefox)',
            proxy: 'optional - scheme://proxy_host:port',
            with_tor: 'optional - boolean (defaults to false)'
          )
          puts "browser_obj.public_methods"

          browser_obj = #{self}.open(
            q: 'required search string'
          )

          browser_obj = #{self}.onion(
            browser_obj: 'required - browser_obj returned from #open method'
          )

          browser_obj = #{self}.close(
            browser_obj: 'required - browser_obj returned from #open method'
          )

          #{self}.authors
        }
      end
    end
  end
end
