# frozen_string_literal: true

require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    # TODO: Convert all rest requests to POST instead of GET
    module TwitterAPI
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # authz_token = CSI::Plugins::TwitterAPI.login(
      #   host: 'required - host/ip of TwitterAPI Server',
      #   port: 'optional - port of TwitterAPI server (defaults to 8000)',
      #   username: 'required - username to AuthN w/ api v2)',
      #   password: 'optional - defect dojo api key (will prompt if nil)'
      # )

      public

      def self.login(opts = {})
        http_body = {}

        host = opts[:host]
        port = if opts[:port]
                 opts[:port].to_i
               else
                 8000
               end

        http_body[:username] = opts[:username].to_s.scrub

        if (host.include?('https://') && port == 443) || (host.include?('http://') && port == 80)
          base_dd_api_uri = "#{host}/api/v2".to_s.scrub
        else
          base_dd_api_uri = "#{host}:#{port}/api/v2".to_s.scrub
        end

        http_body[:password] = if opts[:password].nil?
                                 CSI::Plugins::AuthenticationHelper.mask_password
                               else
                                 opts[:password].to_s.scrub
                               end

        http_headers = {}
        http_headers[:content_type] = 'application/json'

        @@logger.info("Logging into TwitterAPI REST API: #{base_dd_api_uri}")
        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        response = rest_client.execute(
          method: :post,
          url: "#{base_dd_api_uri}/api-token-auth/",
          verify_ssl: false,
          headers: http_headers,
          payload: http_body.to_json
        )

        # Return array containing the post-authenticated TwitterAPI REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        authz_token = json_response[:token]

        return authz_token
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # twitter_rest_call(
      #   authz_token: 'required authz_token returned from #login method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private_class_method def self.twitter_rest_call(opts = {})
        authz_token = opts[:authz_token]
        rest_call = opts[:rest_call].to_s.scrub
        http_method = if opts[:http_method].nil?
                        :get
                      else
                        opts[:http_method].to_s.scrub.to_sym
                      end
        params = opts[:params]
        http_body = opts[:http_body].to_s.scrub
        host = authz_token[:host]
        port = authz_token[:port]
        base_zap_api_uri = "http://#{host}:#{port}"

        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

        case http_method
        when :get
          response = rest_client.execute(
            method: :get,
            url: "#{base_zap_api_uri}/#{rest_call}",
            headers: {
              params: params
            },
            verify_ssl: false
          )

        when :post
          response = rest_client.execute(
            method: :post,
            url: "#{base_zap_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8'
            },
            payload: http_body,
            verify_ssl: false
          )

        else
          raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
        end

        sleep 3

        return response
      rescue StandardError, SystemExit, Interrupt => e
        logout(authz_token) unless authz_token.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::TwitterAPI.logout(
      #   authz_token: 'required authz_token returned from #login method'
      # )

      public

      def self.logout(opts = {})
        authz_token = opts[:authz_token]
        @@logger.info('Logging out...')
        # TODO: Terminate Session if Possible via API Call
        authz_token = nil
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
          authz_token = #{self}.login(
            host: 'required - host/ip of TwitterAPI Server',
            port: 'optional - port of TwitterAPI server (defaults to 8000)',
            username: 'required - username to AuthN w/ api v2)',
            password: 'optional - defect dojo api key (will prompt if nil)'
          )

          #{self}.logout(
            authz_token: 'required authz_token returned from #login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
