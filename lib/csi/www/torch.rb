module CSI
  module WWW
    # This plugin supports Torch (Tor Search Engine) actions.
    module Torch
      # Supported Method Parameters::
      # CSI::WWW::Torch.open(
      #   :browser_type => :firefox|:chrome|:ie|:headless|:rest, 
      #   :proxy => 'optional http(s)://proxy_host:port',
      #   :with_tor => 'optional boolean (defaults to false)'
      # )

      @@logger = CSI::Plugins::CSILogger.create()

      public
      def self.open(opts = {})
        begin
          if $browser
            @@logger.info("leveraging existing $browser object...")
            @@logger.info("run $browser.close to end session.")
          else
            if opts[:browser_type].nil? 
              browser_type = :firefox
            else          
              browser_type = opts[:browser_type]
            end

            proxy = opts[:proxy].to_s unless opts[:proxy].nil?

            if opts[:with_tor]
              with_tor = true
            else
              with_tor = false
            end

            if opts[:with_tor].nil?
              with_tor = true
            else
              with_tor = false
            end

            @@logger.info("instantiating new $browser object...")
            @@logger.info("run $browser.close to end session.")
            if proxy
              if with_tor
                $browser = CSI::Plugins::TransparentBrowser.open(
                  :browser_type => browser_type,
                  :proxy => proxy,
                  :with_tor => true
                )
              else
                $browser = CSI::Plugins::TransparentBrowser.open(
                  :browser_type => browser_type,
                  :proxy => proxy
                )
              end
            else
              $browser = CSI::Plugins::TransparentBrowser.open(
                :browser_type => browser_type
              )
            end
          end

          @@logger.warn("The method #{self}.onion has better anonymity...currently leveraging Tor2web URI:")

          if $browser
            $browser.goto('https://www.xmh57jrzrnw6insl.onion.to')
            CSI::Plugins::TransparentBrowser.linkout(:browser_obj => $browser)
          end

        rescue => e
          puts "Error: #{e.message}"
          return nil
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Torch.open(
      #   :q => 'required search string'
      # )
      public
      def self.search(opts = {})
        q = opts[:q].to_s

        if $browser
          $browser.text_field(:name => 'q').when_present.set(q)
          $browser.button(:name => 'cmd').when_present.click
          sleep 3 # Cough: <hack>
          CSI::Plugins::TransparentBrowser.linkout(:browser_obj => $browser)
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Torch.onion
      public
      def self.onion
        puts %Q{Be sure the $browser object has the following parameters set:

          #{self}.open(
            :browser_type => :chrome, 
            :proxy => 'socks5://127.0.0.1:9050', 
            :with_tor => true
          )
        }
        if $browser
          $browser.goto('http://xmh57jrzrnw6insl.onion')
          CSI::Plugins::TransparentBrowser.linkout(:browser_obj => $browser)
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Torch.close
      public
      def self.close
        $browser = CSI::Plugins::TransparentBrowser.close(:browser_obj => $browser)
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
          #{self}.open(
            :browser_type => 'optional :firefox|:chrome|:ie|:headless|:rest (Defaults to :firefox)', 
            :proxy => 'optional http(s)://proxy_host:port',
            :with_tor => 'optional boolean (defaults to false)'
          )
          puts "$browser.public_methods"

          #{self}.open(
            :q => 'required search string'
          )

          #{self}.onion 

          #{self}.close

          #{self}.authors
        }
      end
    end
  end
end
