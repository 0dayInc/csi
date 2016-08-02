module CSI
  module WWW
    # This plugin supports Pastebin actions.
    module Pastebin
      # Supported Method Parameters::
      # CSI::WWW::Pastebin.open(
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

            @@logger.info("instantiating new $browser object...")
            @@logger.info("run $browser.close to end session.")
            if proxy
              if with_tor
                $browser = CSI::Plugins::TransparentBrowser.open(
                  :browser_type => browser_type,
                  :proxy => proxy,
                  :with_tor => with_tor
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

          if $browser
            $browser.goto('https://pastebin.com')
            CSI::Plugins::TransparentBrowser.linkout(:browser_obj => $browser)
          end

        rescue => e
          puts "Error: #{e.message}"
          return nil
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Pastebin.onion
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
          $browser.goto('http://lw4ipk5choakk5ze.onion')
          CSI::Plugins::TransparentBrowser.linkout(:browser_obj => $browser)
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Pastebin.close
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

          #{self}.onion

          #{self}.close

          #{self}.authors
        }
      end
    end
  end
end
