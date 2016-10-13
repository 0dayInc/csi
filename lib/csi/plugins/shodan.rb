require 'json'

module CSI
  module Plugins
    # This plugin is used for interacting w/ Shodan's REST API using
    # the 'rest' browser type of CSI::Plugins::TransparentBrowser.
    #  This is based on the following Shodan API Specification:
    # https://developer.shodan.io/api
    module Shodan

      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # shodan_rest_call(
      #   :api_key => 'required - shodan api key',
      #   :http_method => 'optional HTTP method (defaults to GET)
      #   :rest_call => 'required rest call to make per the schema',
      #   :params => 'optional params passed in the URI or HTTP Headers',
      #   :http_body => 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )
      private
      def self.shodan_rest_call(opts = {})
        shodan_obj = opts[:shodan_obj]
        if opts[:http_method].nil?
          http_method = :get
        else
          http_method = opts[:http_method].to_s.scrub.to_sym
        end
        rest_call = opts[:rest_call].to_s.scrub
        params = opts[:params]
        http_body = opts[:http_body].to_s.scrub
        base_shodan_api_uri = "https://api.shodan.io"
        api_key = opts[:api_key]
        
        begin
          rest_client = CSI::Plugins::TransparentBrowser.open(:browser_type => :rest)::Request

          case http_method 
            when :get
              response = rest_client.execute(
                :method => :get,
                :url => "#{base_shodan_api_uri}/#{rest_call}",
                :headers => {
                  :content_type => "application/json; charset=UTF-8",
                  :params => params
                }
              )

            when :post
              response = rest_client.execute(
                :method => :post,
                :url => "#{base_shodan_api_uri}/#{rest_call}",
                :headers => {
                  :content_type => "application/json; charset=UTF-8"
                },
                :payload => http_body
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
      # services_by_ips = CSI::Plugins::Shodan.services_by_ips(
      #   :api_key => 'required shodan api key',
      #   :target_ips => 'required - comma-delimited list of ip addresses to target'
      # )
      public
      def self.services_by_ips(opts = {})
        api_key = opts[:api_key].to_s.scrub
        target_ips = opts[:target_ips].to_s.scrub.gsub(/\s/, "").split(",")

        begin
          services_by_ips = []
          params = { :key => api_key }
          target_ips.each do |target_ip|
            response = shodan_rest_call(
              :api_key => api_key, 
              :rest_call => "shodan/host/#{target_ip}",
              :params => params
            )
            services_by_ips.push(JSON.parse(response))
          end
          return services_by_ips
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # query_result_totals = CSI::Plugins::Shodan.query_result_totals(
      #   :api_key => 'required shodan api key',
      #   :query => 'required - shodan search query',
      #   :facets => 'optional - comma-separated list of properties to get summary information'
      # )
      public
      def self.query_result_totals(opts = {})
        api_key = opts[:api_key].to_s.scrub
        query = opts[:query].to_s.scrub
        facets = opts[:facets].to_s.scrub

        begin
          if facets
            params = { 
              :key => api_key,
              :query => query,
              :facets => facets
            }

            response = shodan_rest_call(
              :api_key => api_key, 
              :rest_call => "shodan/host/count",
              :params => params
            )
          else
            params = { 
              :key => api_key,
              :query => query
            }

            response = shodan_rest_call(
              :api_key => api_key, 
              :rest_call => "shodan/host/count",
              :params => params
            )
          end
          query_result_totals = JSON.parse(response)
          return query_result_totals
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # search_results = CSI::Plugins::Shodan.search(
      #   :api_key => 'required shodan api key',
      #   :query => 'required - shodan search query',
      #   :facets => 'optional - comma-separated list of properties to get summary information'
      # )
      public
      def self.search(opts = {})
        api_key = opts[:api_key].to_s.scrub
        query = opts[:query].to_s.scrub
        facets = opts[:facets].to_s.scrub

        begin
          if facets
            params = { 
              :key => api_key,
              :query => query,
              :facets => facets
            }

            response = shodan_rest_call(
              :api_key => api_key, 
              :rest_call => "shodan/host/search",
              :params => params
            )
          else
            params = { 
              :key => api_key,
              :query => query
            }

            response = shodan_rest_call(
              :api_key => api_key, 
              :rest_call => "shodan/host/search",
              :params => params
            )
          end
          query_result_totals = JSON.parse(response)
          return query_result_totals
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # tokens_result = CSI::Plugins::Shodan.tokens(
      #   :api_key => 'required shodan api key',
      #   :query => 'required - shodan search query',
      # )
      public
      def self.tokens(opts = {})
        api_key = opts[:api_key].to_s.scrub
        query = opts[:query].to_s.scrub

        begin
          params = { 
            :key => api_key,
            :query => query
          }

          response = shodan_rest_call(
            :api_key => api_key, 
            :rest_call => "shodan/host/search/tokens",
            :params => params
          )
          query_result_totals = JSON.parse(response)
          return query_result_totals
        rescue => e
          raise e.message
          exit
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
          services_by_ips = #{self}.services_by_ips(
            :api_key => 'required - shodan api key',
            :target_ips => 'required - comma-delimited list of ip addresses to target'
          )

          query_result_totals = CSI::Plugins::Shodan.query_result_totals(
            :api_key => 'required shodan api key',
            :query => 'required - shodan search query',
            :facets => 'optional - comma-separated list of properties to get summary information'
          )

          search_results = #{self}.search(
            :api_key => 'required shodan api key',
            :query => 'required - shodan search query',
            :facets => 'optional - comma-separated list of properties to get summary information'
          )

          tokens_result = #{self}.tokens(
            :api_key => 'required shodan api key',
            :query => 'required - shodan search query',
          )

          #{self}.authors
        }
      end
    end
  end
end
