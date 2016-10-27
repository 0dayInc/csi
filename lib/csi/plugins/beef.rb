# frozen_string_literal: true
require 'json'

module CSI
  module Plugins
    # This plugin is used for interacting w/ BeEF's REST API using
    # the 'rest' browser type of CSI::Plugins::TransparentBrowser.
    module BeEF

      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # beef_obj = CSI::Plugins::BeEF.login(
      #   :beef_ip => 'required - host/ip of IBM Appscan Server',
      #   :beef_port => 'optional - port of BeEF server (defaults to 3000)',
      #   :username => 'required - username',
      #   :password => 'optional - password (will prompt if nil)'
      # )
      public
      def self.login(opts = {})
        beef_ip = opts[:beef_ip]
        if opts[:beef_port]
          beef_port = opts[:beef_port].to_i
        else
          beef_port = 3000
        end

        username = opts[:username].to_s.scrub
        base_beef_api_uri = "http://#{beef_ip}:#{beef_port}/api".to_s.scrub

        if opts[:password].nil?
          password = CSI::Plugins::AuthenticationHelper.mask_password
        else
          password = opts[:password].to_s.scrub
        end

        begin
          auth_payload = {}
          auth_payload[:username] = username
          auth_payload[:password] = password

          @@logger.info("Logging into BeEF REST API: #{beef_ip}")
          rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
          response = rest_client.execute(
            method: :post,
            url: "#{base_beef_api_uri}/admin/login",
            payload: auth_payload.to_json
          )

          # Return array containing the post-authenticated BeEF REST API token
          json_response = JSON.parse(response)
          beef_success = json_response['success']
          api_token = json_response['token']
          beef_obj = {}
          beef_obj[:beef_ip] = beef_ip
          beef_obj[:beef_port] = beef_port
          beef_obj[:beef_success] = beef_success
          beef_obj[:api_token] = api_token
          beef_obj[:raw_response] = response

          return beef_obj
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # beef_rest_call(
      #   :beef_obj => 'required beef_obj returned from #login method',
      #   :http_method => 'optional HTTP method (defaults to GET)
      #   :rest_call => 'required rest call to make per the schema',
      #   :http_body => 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )
      private
      def self.beef_rest_call(opts = {})
        beef_obj = opts[:beef_obj]
        if opts[:http_method].nil?
          http_method = :get
        else
          http_method = opts[:http_method].to_s.scrub.to_sym
        end
        rest_call = opts[:rest_call].to_s.scrub
        http_body = opts[:http_body].to_s.scrub
        beef_success = beef_obj[:beef_success].to_s.scrub
        beef_ip = beef_obj[:beef_ip].to_s.scrub
        beef_port = beef_obj[:beef_port].to_i
        base_beef_api_uri = "http://#{beef_ip}:#{beef_port}/api".to_s.scrub
        api_token = beef_obj[:api_token]

        begin
          rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

          case http_method
            when :get
              response = rest_client.execute(
                method: :get,
                url: "#{base_beef_api_uri}/#{rest_call}",
                headers: {
                  content_type: 'application/json; charset=UTF-8',
                  params: { token: api_token }
                }
              )

            when :post
              response = rest_client.execute(
                method: :post,
                url: "#{base_beef_api_uri}/#{rest_call}",
                headers: {
                  content_type: 'application/json; charset=UTF-8'
                },
                payload: http_body
              )

          else
            raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
            exit
          end
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # hooks = CSI::Plugins::BeEF.hooks(
      #   :beef_obj => 'required beef_obj returned from #login method'
      # )
      public
      def self.hooks(opts = {})
        beef_obj = opts[:beef_obj]
        @@logger.info('Retrieving BeEF Hooks...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: 'hooks'
          )

          hooks = JSON.parse(response)
          return hooks
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # hooked_browser_info = CSI::Plugins::BeEF.hooked_browser_info(
      #   :beef_obj => 'required beef_obj returned from #login method',
      #   :browser_session => 'required - browser session id returned from #hooks method'
      # )
      public
      def self.hooked_browser_info(opts = {})
        beef_obj = opts[:beef_obj]
        browser_session = opts[:browser_session].to_s.scrub

        @@logger.info('Retrieving Browser Info...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: "hooks/#{browser_session}"
          )

          hooked_browser_info = JSON.parse(response)
          return hooked_browser_info
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # logs = CSI::Plugins::BeEF.logs(
      #   :beef_obj => 'required beef_obj returned from #login method'
      # )
      public
      def self.logs(opts = {})
        beef_obj = opts[:beef_obj]
        @@logger.info('Retrieving BeEF Logs...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: 'logs'
          )

          logs = JSON.parse(response)
          return logs
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # hooked_browser_logs = CSI::Plugins::BeEF.hooked_browser_logs(
      #   :beef_obj => 'required beef_obj returned from #login method',
      #   :browser_session => 'required - browser session id returned from #hooks method'
      # )
      public
      def self.hooked_browser_logs(opts = {})
        beef_obj = opts[:beef_obj]
        browser_session = opts[:browser_session].to_s.scrub

        @@logger.info('Retrieving Browser Logs...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: "logs/#{browser_session}"
          )

          hooked_browser_logs = JSON.parse(response)
          return hooked_browser_logs
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # modules = CSI::Plugins::BeEF.modules(
      #   :beef_obj => 'required beef_obj returned from #login method'
      # )
      public
      def self.modules(opts = {})
        beef_obj = opts[:beef_obj]
        @@logger.info('Retrieving BeEF Modules...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: 'modules'
          )

          logs = JSON.parse(response)
          return logs
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # module_info = CSI::Plugins::BeEF.module_info(
      #   :beef_obj => 'required beef_obj returned from #login method',
      #   :module_id => 'required - module id returned from #modules method'
      # )
      public
      def self.module_info(opts = {})
        beef_obj = opts[:beef_obj]
        module_id = opts[:module_id].to_i

        @@logger.info('Retrieving Module Info...')
        begin
          response = beef_rest_call(
            beef_obj: beef_obj,
            rest_call: "modules/#{module_id}"
          )

          module_info = JSON.parse(response)
          return module_info
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BeEF.logout(
      #   :beef_obj => 'required beef_obj returned from #login method'
      # )
      public
      def self.logout(opts = {})
        beef_obj = opts[:beef_obj]
        @@logger.info('Logging out...')
        beef_obj = nil
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts "USAGE:
          beef_obj = #{self}.login(
            :beef_ip => 'required host/ip of Nexpose Console (server)',
            :beef_port => 'optional - port of BeEF server (defaults to 3000)',
            :username => 'required username',
            :password => 'optional password (will prompt if nil)'
          )

          hooks = #{self}.hooks(
            :beef_obj => 'required beef_obj returned from #login method'
          )

          hooked_browser_info = #{self}.hooked_browser_info(
            :beef_obj => 'required beef_obj returned from #login method',
            :browser_session => 'required - browser session id returned from #hooks method'
          )

          logs = #{self}.logs(
            :beef_obj => 'required beef_obj returned from #login method'
          )

          hooked_browser_logs = #{self}.hooked_browser_logs(
            :beef_obj => 'required beef_obj returned from #login method',
            :browser_session => 'required - browser session id returned from #hooks method'
          )

          modules = #{self}.modules(
            :beef_obj => 'required beef_obj returned from #login method'
          )

          module_info = #{self}.module_info(
            :beef_obj => 'required beef_obj returned from #login method',
            :module_id => 'required - module id returned from #modules method'
          )

          beef_obj = #{self}.logout(
            :beef_obj => 'required beef_obj returned from #login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
