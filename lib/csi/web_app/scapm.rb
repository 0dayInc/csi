# frozen_string_literal: true
require 'sinatra'
require 'onelogin/ruby-saml'

module CSI
  module WebApp
    # This plugin was initially created to support phishing efforts, however, this is basically a blank plugin that can be used as a skeleton template for building other plugins.
    module SCAPM
      # Main Class that Comprises the Entire Web Application
      class Application < Sinatra::Base
        private

        def saml_settings
          idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
          # Returns OneLogin::RubySaml::Settings prepopulated with idp metadata
          settings = idp_metadata_parser.parse_remote('https://example.com/auth/saml2/idp/metadata')

          settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
          settings.issuer                         = "http://#{request.host}/saml/metadata"
          settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
          # Optional for most SAML IdPs
          settings.authn_context = 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'

          settings
        end

        configure do
          set :cache_control, :no_store
          set :static_cache_control, :no_store
        end

        get '/?' do
          'Please Authenticate w/ OneLogin Credentials'
        end

        get '/saml/authentication_request' do
          request = OneLogin::RubySaml::Authrequest.new
          redirect request.create(saml_settings)
        end

        post '/saml/artifact' do
          response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_settings)
          if response.is_valid?
            "Success! #{response.nameid}, #{response.attributes}"
          else
            'Error'
          end
        end

        get '/saml/metadata' do
          meta = OneLogin::RubySaml::Metadata.new
          content_type 'text/xml'
          meta.generate(saml_settings, true)
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::WebServer.start(
      #   No Method Parameters Implemented.
      # )

      public

      def self.start
        self::Application.run!
      end

      # Supported Method Parameters::
      # CSI::Plugins::WebServer.stop(
      #   No Method Parameters Implemented.
      # )

      public

      def self.stop
        # Stop spear phishing server ;)
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
          #{self}.start

          #{self}.stop

          #{self}.authors
        "
      end
    end
  end
end
