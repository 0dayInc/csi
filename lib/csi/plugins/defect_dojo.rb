# frozen_string_literal: true

require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    # TODO: Convert all rest requests to POST instead of GET
    module DefectDojo
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # dd_obj = CSI::Plugins::DefectDojo.login(
      #   dd_ip: 'required - host/ip of IBM Appscan Server',
      #   dd_port: 'optional - port of DefectDojo server (defaults to 8000)',
      #   username: 'required - username',
      #   password: 'optional - password (will prompt if nil)'
      # )

      public

      def self.login(opts = {})
        dd_ip = opts[:dd_ip]
        dd_port = if opts[:dd_port]
                      opts[:dd_port].to_i
                    else
                      3000
                    end

        username = opts[:username].to_s.scrub
        base_dd_api_uri = "http://#{dd_ip}:#{dd_port}/api".to_s.scrub

        password = if opts[:password].nil?
                     CSI::Plugins::AuthenticationHelper.mask_password
                   else
                     opts[:password].to_s.scrub
                   end

        auth_payload = {}
        auth_payload[:username] = username
        auth_payload[:password] = password

        @@logger.info("Logging into DefectDojo REST API: #{dd_ip}")
        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        response = rest_client.execute(
          method: :post,
          url: "#{base_dd_api_uri}/admin/login",
          payload: auth_payload.to_json
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response)
        dd_success = json_response['success']
        api_token = json_response['token']
        dd_obj = {}
        dd_obj[:dd_ip] = dd_ip
        dd_obj[:dd_port] = dd_port
        dd_obj[:dd_success] = dd_success
        dd_obj[:api_token] = api_token
        dd_obj[:raw_response] = response

        return dd_obj
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # defect_dojo_rest_call(
      #   dd_obj: 'required dd_obj returned from #login method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private_class_method def self.dd_rest_call(opts = {})
        dd_obj = opts[:dd_obj]
        rest_call = opts[:rest_call].to_s.scrub
        http_method = if opts[:http_method].nil?
                        :get
                      else
                        opts[:http_method].to_s.scrub.to_sym
                      end
        params = opts[:params]
        http_body = opts[:http_body].to_s.scrub
        host = dd_obj[:host]
        port = dd_obj[:port]
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
        logout(dd_obj) unless dd_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::DefectDojo.logout(
      #   dd_obj: 'required dd_obj returned from #login method'
      # )

      public

      def self.logout(opts = {})
        dd_obj = opts[:dd_obj]
        @@logger.info('Logging out...')
        # TODO: Terminate Session if Possible via API Call
        dd_obj = nil
      rescue => e
        raise e.message
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
          #{self}.authors
        "
      end
    end
  end
end
