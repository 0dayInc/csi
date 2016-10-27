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
        base_shodan_api_uri = 'https://api.shodan.io'
        api_key = opts[:api_key]
        
        begin
          rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

          case http_method 
            when :get
              response = rest_client.execute(
                method: :get,
                url: "#{base_shodan_api_uri}/#{rest_call}",
                headers: {
                  content_type: 'application/json; charset=UTF-8',
                  params: params
                },
                verify_ssl: false
              )

            when :post
              response = rest_client.execute(
                method: :post,
                url: "#{base_shodan_api_uri}/#{rest_call}",
                headers: {
                  content_type: 'application/json; charset=UTF-8',
                  params: params
                },
                payload: http_body,
                verify_ssl: false
              )

          else
            raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
            exit
          end
          return response
        rescue => e
          case e.message
            when'404 Resource Not Found'
              return "#{e.message}: #{e.response}"
            when '400 Bad Request'
              return "#{e.message}: #{e.response}"
          else
            raise "#{e.message}: #{e.response}"
            exit
          end
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
        target_ips = opts[:target_ips].to_s.scrub.gsub(/\s/, '').split(',')

          services_by_ips = []
          params = { key: api_key }
          target_ips.each do |target_ip|
          begin
            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: "shodan/host/#{target_ip}",
              params: params
            )
            services_by_ips.push(JSON.parse(response))
          rescue => e
            services_by_ips.push({error: e.message})
            next
          end
        end
        return services_by_ips
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
              key: api_key,
              query: query,
              facets: facets
            }

            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: 'shodan/host/count',
              params: params
            )
          else
            params = { 
              key: api_key,
              query: query
            }

            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: 'shodan/host/count',
              params: params
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
              key: api_key,
              query: query,
              facets: facets
            }

            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: 'shodan/host/search',
              params: params
            )
          else
            params = { 
              key: api_key,
              query: query
            }

            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: 'shodan/host/search',
              params: params
            )
          end
          search_results = JSON.parse(response)
          return search_results
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
            key: api_key,
            query: query
          }

          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/host/search/tokens',
            params: params
          )
          tokens_result = JSON.parse(response)
          return tokens_result
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # ports_shodan_crawls = CSI::Plugins::Shodan.ports_shodan_crawls(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.ports_shodan_crawls(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/ports',
            params: params
          )
          ports_shodan_crawls = JSON.parse(response)
          return ports_shodan_crawls
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # protocols = CSI::Plugins::Shodan.list_on_demand_scan_protocols(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.list_on_demand_scan_protocols(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/protocols',
            params: params
          )
          protocols = JSON.parse(response)
          return protocols
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # scan__networkresponse = CSI::Plugins::Shodan.scan_network(
      #   :api_key => 'required shodan api key',
      #   :target_ips => 'required - comma-delimited list of ip addresses to target'
      # )
      public
      def self.scan_network(opts = {})
        api_key = opts[:api_key].to_s.scrub
        target_ips = opts[:target_ips].to_s.scrub.gsub(/\s/, '')

        begin
          params = { key: api_key }
          http_body = "ips=#{target_ips}"
          response = shodan_rest_call(
            http_method: :post,
            api_key: api_key, 
            rest_call: 'shodan/scan',
            params: params,
            http_body: http_body
          )
          scan_network_response = JSON.parse(response)
          return scan_network_response
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # scan_internet_response = CSI::Plugins::Shodan.scan_internet(
      #   :api_key => 'required shodan api key',
      #   :port => 'required - port to scan (see #ports_shodan_crawls for list)',
      #   :protocol => 'required - supported shodan protocol (see #list_on_demand_scan_protocols for list)'
      # )
      public
      def self.scan_internet(opts = {})
        api_key = opts[:api_key].to_s.scrub
        port = opts[:port].to_i
        protocol = opts[:protocol].to_s.scrub

        begin
          params = { key: api_key }
          http_body = "port=#{port}&protocol=#{protocol}"
          response = shodan_rest_call(
            http_method: :post,
            api_key: api_key, 
            rest_call: 'shodan/scan/internet',
            params: params,
            http_body: http_body
          )
          scan_internet_response = JSON.parse(response)
          return scan_internet_response
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # scan_status_result = CSI::Plugins::Shodan.scan_status(
      #   :api_key => 'required shodan api key',
      #   :scan_id => 'required - unique ID returned by #scan_network',
      # )
      public
      def self.scan_status(opts = {})
        api_key = opts[:api_key].to_s.scrub
        scan_id = opts[:scan_id].to_s.scrub

        begin
          params = { 
            key: api_key
          }

          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: "shodan/scan/status/#{scan_id}",
            params: params
          )
          scan_status_result = JSON.parse(response)
          return scan_status_result
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # services_shodan_crawls = CSI::Plugins::Shodan.services_shodan_crawls(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.services_shodan_crawls(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/services',
            params: params
          )
          services_shodan_crawls = JSON.parse(response)
          return services_shodan_crawls
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # saved_search_queries_result = CSI::Plugins::Shodan.saved_search_queries(
      #   :api_key => 'required shodan api key',
      #   :page => 'optional - page number to iterate over results (each page contains 10 items)',
      #   :sort => 'optional - sort results by available parameters :votes|:timestamp',
      #   :order => 'optional - sort :asc|:desc (ascending or descending)'
      # )
      public
      def self.saved_search_queries(opts = {})
        api_key = opts[:api_key].to_s.scrub
        page = opts[:page].to_i
        sort = opts[:sort].to_sym
        order = opts[:order].to_sym

        begin
          params = { 
            key: api_key,
            page: page,
            sort: sort.to_s,
            order: order.to_s
          }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/query',
            params: params
          )
          services_shodan_crawls = JSON.parse(response)
          return services_shodan_crawls
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # most_popular_tags_result = CSI::Plugins::Shodan.most_popular_tags(
      #   :api_key => 'required shodan api key',
      #   :result_count => 'optional - number of results to return (defaults to 10)'
      # )
      public
      def self.most_popular_tags(opts = {})
        api_key = opts[:api_key].to_s.scrub
        result_count = opts[:result_count].to_i

        begin
          if result_count
            params = {
              key: api_key,
              size: result_count
            }
          else
            params = { key: api_key }
          end

          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'shodan/query/tags',
            params: params
          )
          most_popular_tags_result = JSON.parse(response)
          return most_popular_tags_result
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # my_profile = CSI::Plugins::Shodan.my_profile(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.my_profile(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'account/profile',
            params: params
          )
          my_profile = JSON.parse(response)
          return my_profile
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # my_pub_ip = CSI::Plugins::Shodan.my_pub_ip(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.my_pub_ip(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'tools/myip',
            params: params
          )
          my_pub_ip = response
          return my_pub_ip
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # api_info = CSI::Plugins::Shodan.api_info(
      #   :api_key => 'required shodan api key'
      # )
      public
      def self.api_info(opts = {})
        api_key = opts[:api_key].to_s.scrub

        begin
          params = { key: api_key }
          response = shodan_rest_call(
            api_key: api_key, 
            rest_call: 'api-info',
            params: params
          )
          api_info = JSON.parse(response)
          return api_info
        rescue => e
          raise e.message
          exit
        end
      end

      # Supported Method Parameters::
      # honeypot_probability_scores = CSI::Plugins::Shodan.honeypot_probability_scores(
      #   :api_key => 'required shodan api key',
      #   :target_ips => 'required - comma-delimited list of ip addresses to target'
      # )
      public
      def self.honeypot_probability_scores(opts = {})
        api_key = opts[:api_key].to_s.scrub
        target_ips = opts[:target_ips].to_s.scrub.gsub(/\s/, '').split(',')

        begin
          honeypot_probability_scores = []
          params = { key: api_key }
          target_ips.each do |target_ip|
            response = shodan_rest_call(
              api_key: api_key, 
              rest_call: "labs/honeyscore/#{target_ip}",
              params: params
            )
            honeypot_probability_scores.push("#{target_ip} => #{response}")
          end
          return honeypot_probability_scores
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

          ports_shodan_crawls = #{self}.ports_shodan_crawls(
            :api_key => 'required shodan api key'
          )

          protocols = #{self}.list_on_demand_scan_protocols(
            :api_key => 'required shodan api key'
          )

          scan_network_response = #{self}.scan_network(
            :api_key => 'required shodan api key',
            :target_ips => 'required - comma-delimited list of ip addresses to target'
          )

          scan_internet_response = #{self}.scan_internet(
            :api_key => 'required shodan api key',
            :port => 'required - port to scan (see #ports_shodan_crawls for list)',
            :protocol => 'required - supported shodan protocol (see #list_on_demand_scan_protocols for list)'
          )

          scan_status_result = #{self}.scan_status(
            :api_key => 'required shodan api key',
            :scan_id => 'required - unique ID returned by #scan_network',
          )

          services_shodan_crawls = #{self}.services_shodan_crawls(
            :api_key => 'required shodan api key'
          )

          saved_search_queries_result = #{self}.saved_search_queries(
            :api_key => 'required shodan api key',
            :page => 'optional - page number to iterate over results (each page contains 10 items)',
            :sort => 'optional - sort results by available parameters :votes|:timestamp',
            :order => 'optional - sort :asc|:desc (ascending or descending)'
          )

          most_popular_tags_result = #{self}.most_popular_tags(
            :api_key => 'required shodan api key',
            :result_count => 'optional - number of results to return (defaults to 10)'
          )

          my_profile = #{self}.my_profile(
            :api_key => 'required shodan api key'
          )

          my_pub_ip = #{self}.my_pub_ip(
            :api_key => 'required shodan api key'
          )

          api_info = #{self}.api_info(
            :api_key => 'required shodan api key'
          )

          honeypot_probability_scores = #{self}.honeypot_probability_scores(
            :api_key => 'required shodan api key',
            :target_ips => 'required - comma-delimited list of ip addresses to target'
          )

          #{self}.authors
        }
      end
    end
  end
end
