# frozen_string_literal: true
require 'yaml'

module CSI
  module WWW
    # This plugin supports Synack actions.
    module Synack
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::WWW::Synack.open(
      #   :browser_type => :firefox|:chrome|:ie|:headless|:rest,
      #   :proxy => 'optional http(s)://proxy_host:port',
      #   :with_tor => 'optional boolean (defaults to false)'
      # )

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
          $browser.goto('https://login.synack.com')
          CSI::Plugins::TransparentBrowser.linkout(browser_obj: $browser)
        end

      rescue => e
        puts "Error: #{e.message}"
        return nil
      end

      # Supported Method Parameters::
      # CSI::WWW::Synack.login(
      #   :yaml_config => 'required - path of yaml file to encrypt',
      #   :vpassfile => 'required - path of ansible-vault pass file'
      # )

      public

      def self.login(opts = {})
        if $browser
          yaml_config = opts[:yaml_config].to_s.scrub if File.exist?(opts[:yaml_config]).to_s.scrub
          vpassfile = opts[:vpassfile].to_s.scrub if File.exist?(opts[:vpassfile]).to_s.scrub

          # decrypt yaml config file
          uiauthn_hash = CSI::Plugins::AnsibleVault.decrypt(
            yaml_config: yaml_config.to_s,
            vpassfile: vpassfile.to_s
          )

          email = uiauthn_hash['uiauthn']['email'].to_s.scrub
          password = uiauthn_hash['uiauthn']['password'].to_s.scrub
          # TODO: Integrate MFA Token Retrieval & Population into text_field
          # authy_id = uiauthn_hash["api"]["authy_id"].to_s.scrub
          # authy_api_key = uiauthn_hash["api"]["key"].to_s.scrub
          # authy_token = ?
          # Authy.api_uri = 'https://api.authy.com/'
          # Authy.api_key = authy_api_key

          $browser.text_field(name: 'email').when_present.set(email)
          $browser.text_field(name: 'password').when_present.set(password)
          $browser.button(class: 'btn').when_present.click # no name or id in button element
          @@logger.info('mfa prompt initiated...')
          until $browser.url == 'https://platform.synack.com/'
            print 'enter authy mfa token: '
            authy_token = gets.to_i
            $browser.text_field(name: 'authy_token').when_present.set(authy_token)
            $browser.button(class: 'btn').when_present.click # no name or id in button element
            sleep 3 # TODO: fixme this is a <cough> hack
          end
          print "\n"
          @@logger.info('authy token accepted.')
          CSI::Plugins::TransparentBrowser.linkout(browser_obj: $browser)
        end
      rescue
      ensure
        uiauthn_hash = nil
      end

      # Supported Method Parameters::
      # CSI::WWW::Synack.logout

      public

      def self.logout
        if $browser
          $browser.img(class: 'navbar-avatar-img').click
          $browser.button(text: 'Logout').click
        end
      end

      # Supported Method Parameters::
      # CSI::WWW::Synack.close

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
            :browser_type => 'optional :firefox|:chrome|:ie|:headless|:rest (Defaults to :firefox)',
            :proxy => 'optional http(s)://proxy_host:port',
            :with_tor => 'optional boolean (defaults to false)'
          )
          puts "$browser.public_methods"

          #{self}.login(
            :yaml_config => 'required - encrypted ansible-vault yaml file',
            :vpassfile => 'required - ansible-vault pass file'
          )

          #{self}.logout

          #{self}.close

          #{self}.authors
        }
      end
    end
  end
end
