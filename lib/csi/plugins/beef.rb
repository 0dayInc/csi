require 'json'

module CSI
  module Plugins
    # This plugin is used for interacting w/ BeEF's REST API using
    # the 'rest' browser type of CSI::Plugins::TransparentBrowser.
    module BeEF

      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::BeEF.login(
      #   :beef_ip => 'required - host/ip of IBM Appscan Server', 
      #   :beef_port => 'optional - port of BeEF server (defaults to 3000)',
      #   :username => 'required - username', 
      #   :password => 'optional - password (will prompt if nil)'
      # )
      public
      def self.login(opts = {})
        beef_ip = opts[:beef_ip]
        if opts[:beef_port]
          beef_ip = opts[:beef_port].to_i
        else
          beef_ip = 3000
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
          rest_client = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest)::Request
          response = rest_client.execute(
            :method => :post,
            :url => "#{base_beef_api_uri}/admin/login",
            :payload => auth_payload.to_json
          )

          # Return array containing the post-authenticated BeEF REST API token
          json_response = JSON.parse(response)
          beef_success = json_response["success"]
          beef_token = json_response["token"]
          beef_obj = {}
          beef_obj[:success] = beef_success
          beef_obj[:token] = beef_token
          beef_obj[:raw_response] = response

          return beef_obj
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # beef_rest_call(
      #   :beef_obj => 'required beef_obj returned from login method',
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
        beef_ip = beef_obj[:beef_ip].to_s.scrub
        beef_cookie = beef_obj[:cookie]
        base_beef_api_uri = "https://#{beef_ip}/ase/services".to_s.scrub
        api_token = opts[:api_token]
        retry_count = 3
        
        begin
          rest_client = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest)::Request

          case http_method 
            when :get
              response = rest_client.execute(
                :method => :get,
                :url => "#{base_beef_api_uri}/#{rest_call}",
                :headers => { :cookie => beef_cookie },
                :verify_ssl => false
              )

            when :post
              response = rest_client.execute(
                :method => :post,
                :url => "#{base_beef_api_uri}/#{rest_call}",
                :headers => { :cookie => beef_cookie },
                :payload => http_body,
                :verify_ssl => false
              )

          else
            return @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
          end
          return response
        rescue => e
          if e.message == "401 Unauthorized" and retry_count > 0 and beef_obj[:logged_in]
            # Try logging back in to refresh the connection
            @@logger.warn("Got Response: #{e.message}...Attempting to Re-Authenticate; Retries left #{retry_count}")
            n_beef_obj = self.login(
              :beef_ip => beef_obj[:beef_ip],
              :username => beef_obj[:username],
              :password => Base64.decode64(beef_obj[:password])
            )
            beef_cookie = n_beef_obj[:cookie]
            # "copy" the new app obj over the old app obj
            beef_obj.keys.each do |k|
              beef_obj[k] = n_beef_obj[k]
            end
            retry_count-=1
            retry
          end
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::BeEF.logout(
      #   :beef_obj => 'required beef_obj returned from login method'
      # )
      public
      def self.logout(opts = {})
        beef_obj = opts[:beef_obj]
        @@logger.info("Logging out...")
        response = beef_rest_call(:beef_obj => beef_obj, :rest_call => "logout")
        if response == ""
          beef_obj[:logged_in] = false
          return "logout successful"
        else
          return response
        end
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
          beef_obj = #{self}.login(
            :beef_ip => 'required host/ip of Nexpose Console (server)', 
            :username => 'required username', 
            :password => 'optional password (will prompt if nil)'
          )

          #{self}.logout(
            :beef_obj => 'required beef_obj returned from login method'
          )

          #{self}.authors
        }
      end
    end
  end
end
