# frozen_string_literal: true
require 'yaml'

module CSI
  module WWW
    # This plugin supports app.cobalt.io actions.
    module AppCobaltIO
      # Supported Method Parameters::
      # browser_obj = CSI::WWW::AppCobaltIO.open(
      #   browser_type: :firefox|:chrome|:ie|:headless,
      #   proxy: 'optional - http(s)://proxy_host:port',
      #   with_tor: 'optional - boolean (defaults to false)'
      # )

      public

      def self.open(opts = {})
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

        if proxy
          if with_tor
            browser_obj = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type,
              proxy: proxy,
              with_tor: with_tor
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

        browser_obj.goto('https://app.cobalt.io')

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::AppCobaltIO.login(
      #   browser_obj: 'required - browser_obj returned from #open method',
      #   username: 'required - username',
      #   password: 'optional - passwd (will prompt if blank),
      #   mfa: 'optional - if true prompt for mfa token (defaults to false)'
      # )

      public

      def self.login(opts = {})
        browser_obj = opts[:browser_obj]
        username = opts[:username].to_s.scrub.strip.chomp
        password = opts[:password]

        if password.nil?
          CSI::Plugins::AuthenticationHelper.mask_password
        else
          opts[:password].to_s
        end
        mfa = opts[:mfa]

        browser_obj.goto('https://app.cobalt.io/users/sign_in')

        browser_obj.text_field(id: 'user_email').wait_until_present.set(email)
        browser_obj.text_field(id: 'user_password').wait_until_present.set(password)
        browser_obj.button(name: 'commit').wait_until_present.click # no name or id in button element

        if mfa
          until browser_obj.url == 'https://app.cobalt.io/dashboard'
            print 'enter mfa token: '
            authy_token = gets.to_i
            browser_obj.text_field(id: 'code').wait_until_present.set(authy_token)
            browser_obj.button(name: 'commit').wait_until_present.click # no name or id in button element
          end
          print "\n"
        end

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::AppCobaltIO.logout(
      #   browser_obj: 'required - browser_obj returned from #open method'
      # )

      public

      def self.logout
        browser_obj = opts[:browser_obj]
        browser_obj.li(class: 'user-dropdown').click
        browser_obj.a(href: '/users/signout').click

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::AppCobaltIO.close(
      #   browser_obj: 'required - browser_obj returned from #open method'
      # )

      public

      def self.close
        browser_obj = opts[:browser_obj]
        browser_obj = CSI::Plugins::TransparentBrowser.close(browser_obj: browser_obj)
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
        puts %{USAGE:
          #{self}.open(
            browser_type: 'optional - :firefox|:chrome|:ie|:headless (Defaults to :firefox)',
            proxy: 'optional - http(s)://proxy_host:port',
            with_tor: 'optional - boolean (defaults to false)'
          )
          puts "browser_obj.public_methods"

          #{self}.login(
            browser_obj: 'required - browser_obj returned from #open method',
            username: 'required - username',
            password: 'optional - passwd (will prompt if blank),
            mfa: 'optional - if true prompt for mfa token (defaults to false)'
          )

          browser_obj = #{self}.logout(
            browser_obj: 'required - browser_obj returned from #open method'
          )

          #{self}.close(
            browser_obj: 'required - browser_obj returned from #open method'
          )

          #{self}.authors
        }
      end
    end
  end
end
