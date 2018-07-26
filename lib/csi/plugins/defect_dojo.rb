# frozen_string_literal: true

require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    # TODO: Convert all rest requests to POST instead of GET
    module DefectDojo
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # dd_obj = CSI::Plugins::DefectDojo.login_v1(
      #   url: 'required - url of DefectDojo Server',
      #   username: 'required - username to AuthN w/ api v1)',
      #   api_key: 'optional - defect dojo api key (will prompt if nil)',
      #   debug: 'optional - proxy all traffic through http://127.0.0.1:8080 for debug (defaults to false)'
      # )

      public_class_method def self.login_v1(opts = {})
        dd_obj = {}
        dd_obj[:url] = opts[:url]

        username = opts[:username].to_s.scrub

        api_key = if opts[:api_key].nil?
                    CSI::Plugins::AuthenticationHelper.mask_password(
                      prompt: 'API Key'
                    )
                  else
                    opts[:api_key].to_s.scrub
                  end

        dd_obj[:authz_header] = "ApiKey #{username}:#{api_key}"
        dd_obj[:debug] = opts[:debug]

        return dd_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # dd_obj = CSI::Plugins::DefectDojo.login_v2(
      #   url: 'required - url of DefectDojo Server',
      #   username: 'required - username to AuthN w/ api v2)',
      #   password: 'optional - defect dojo api key (will prompt if nil)'
      # )

      public_class_method def self.login_v2(opts = {})
        http_body = {}

        url = opts[:url]

        http_body[:username] = opts[:username].to_s.scrub

        base_dd_api_uri = "#{url}/api/v2".to_s.scrub

        http_body[:password] = if opts[:password].nil?
                                 CSI::Plugins::AuthenticationHelper.mask_password
                               else
                                 opts[:password].to_s.scrub
                               end

        http_headers = {}
        http_headers[:content_type] = 'application/json'

        @@logger.info("Logging into DefectDojo REST API: #{base_dd_api_uri}")
        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        response = rest_client.execute(
          method: :post,
          url: "#{base_dd_api_uri}/api-token-auth/",
          verify_ssl: false,
          headers: http_headers,
          payload: http_body.to_json
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        dd_obj = json_response

        return dd_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # dd_v1_rest_call(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private_class_method def self.dd_v1_rest_call(opts = {})
        # Some scan reports are huge and require long timeouts...defaulting to 9 mins.
        request_timeout = 540

        dd_obj = opts[:dd_obj]
        rest_call = opts[:rest_call].to_s.scrub

        opts[:http_method] ? (http_method = opts[:http_method].to_s.scrub.to_sym) : (http_method = :get)

        params = opts[:params]
        http_body = opts[:http_body]

        content_type = 'application/json; charset=UTF-8'

        url = dd_obj[:url]
        base_dd_api_uri = "#{url}/api/v1".to_s.scrub

        if dd_obj[:debug]
          rest_client = CSI::Plugins::TransparentBrowser.open(
            browser_type: :rest,
            proxy: 'http://127.0.0.1:8080'
          )::Request
        else
          rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        end

        case http_method
        when :get
          response = rest_client.execute(
            method: :get,
            url: "#{base_dd_api_uri}/#{rest_call}",
            headers: {
              content_type: content_type,
              authorization: dd_obj[:authz_header],
              params: params
            },
            verify_ssl: false,
            timeout: request_timeout,
            open_timeout: request_timeout
          )

        when :post
          if http_body.key?(:multipart)
            response = rest_client.execute(
              method: :post,
              url: "#{base_dd_api_uri}/#{rest_call}",
              headers: {
                authorization: dd_obj[:authz_header]
              },
              payload: http_body,
              verify_ssl: false,
              timeout: request_timeout,
              open_timeout: request_timeout
            )
          else
            response = rest_client.execute(
              method: :post,
              url: "#{base_dd_api_uri}/#{rest_call}",
              headers: {
                content_type: content_type,
                authorization: dd_obj[:authz_header]
              },
              payload: http_body.to_json,
              verify_ssl: false,
              timeout: request_timeout,
              open_timeout: request_timeout
            )
          end
        else
          raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
        end

        sleep 3

        return response
      rescue StandardError, SystemExit, Interrupt => e
        dd_obj = logout(dd_obj) unless dd_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # product_list = CSI::Plugins::DefectDojo.product_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   id: 'optional - retrieve single product by id, otherwise return all'
      # )

      public_class_method def self.product_list(opts = {})
        dd_obj = opts[:dd_obj]
        opts[:id] ? (rest_call = "products/#{opts[:id].to_i}") : (rest_call = 'products')

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: rest_call
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        product_list = json_response

        return product_list
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # engagement_list = CSI::Plugins::DefectDojo.engagement_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   id: 'optional - retrieve single engagement by id, otherwise return all'
      # )

      public_class_method def self.engagement_list(opts = {})
        dd_obj = opts[:dd_obj]
        opts[:id] ? (rest_call = "engagements/#{opts[:id].to_i}") : (rest_call = 'engagements')

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: rest_call
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        engagement_list = json_response

        return engagement_list
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # engagement_create_response = CSI::Plugins::DefectDojo.engagement_create(
      #   dd_obj: 'required - dd_obj returned from #login_v1 method',
      #   name: 'required - name of the engagement',
      #   description: 'optional - description of engagement',
      #   engagement_type: 'optional - type of engagement Interactive||CI/CD (defaults to CI/CD)',
      #   status: 'optional - status of the engagement In Progress || On Hold (defaults to In Progress)',
      #   lead_username: 'required - username of lead to tie to engagement',
      #   product_name: 'required - product name in which to create engagement',
      #   test_strategy: 'required - URL of test strategy documentation (e.g. OWASP ASVS URL)',
      #   orchestration_engine: 'optional - name of orchestration engine tied to CI/CD engagement',
      #   build_server: 'optional - name of build server tied to CI/CD engagement',
      #   scm_server: 'optional - name of SCM server tied to CI/CD engagement',
      #   api_test: 'optional - boolean to set an engagement as an api assessment (defaults to false)',
      #   pen_test: 'optional - boolean to set an engagement as a manual penetration test (defaults to false)',
      #   threat_model: 'optional - boolean to set an engagement as a threat model (defaults to false)',
      #   check_list: 'optional - boolean to set an engagement as a checkbox assessment (defaults to false)',
      #   first_contacted: 'optional - date of engagement request e.g. 2018-06-18 (Defaults to current day)',
      #   target_start: 'optional - date to start enagement e.g. 2018-06-19 (Defaults to current day)',
      #   target_end: 'optional - date of engagement completion e.g. 2018-06-20 (Defaults to current day)'
      # )

      public_class_method def self.engagement_create(opts = {})
        http_body = {}

        dd_obj = opts[:dd_obj]

        # HTTP POST body options w/ optional params set to default values
        # Defaults to true
        http_body[:active] = true

        http_body[:name] = opts[:name]

        http_body[:description] = opts[:description]

        opts[:engagment_type] ? (http_body[:engagement_type] = opts[:engagement_type]) : (http_body[:engagement_type] = 'CI/CD')

        status = opts[:status].to_s.strip.chomp.scrub

        case status
        when 'In Progress', 'On Hold', ''
          # Defaults to 'In Progress'
          status == '' ? (http_body[:status] = 'In Progress') : (http_body[:status] = status)
        when 'Completed'
          raise 'Completed status not implemented for #engagement_create - use #engagement_update instead'
        else
          raise "Unknown engagement status: #{opts[:status]}.  Options for this method are 'In Progress' || 'On Hold'"
        end

        # Ok lets determine the resource_uri for the lead username
        lead_username = opts[:lead_username].to_s.strip.chomp.scrub
        user_list = self.user_list(dd_obj: dd_obj)
        user_by_username_object = user_list[:objects].select { |user| user[:username] == lead_username }
        # Should only ever return 1 result so we should be good here
        http_body[:lead] = user_by_username_object.first[:resource_uri]

        # Ok lets determine the resource_uri for the product name
        product_name = opts[:product_name].to_s.strip.chomp.scrub
        product_list = self.product_list(dd_obj: dd_obj)
        product_by_name_object = product_list[:objects].select { |product| product[:name] == product_name }
        # Should only ever return 1 result so we should be good here
        http_body[:product] = product_by_name_object.first[:resource_uri]

        http_body[:test_strategy] = opts[:test_strategy]
        http_body[:orchestration_engine] = opts[:orchestration_engine]
        http_body[:build_server] = opts[:build_server]
        http_body[:scm_server] = opts[:scm_server]

        # Defaults to false
        opts[:api_test] ? (http_body[:api_test] = true) : (http_body[:api_test] = false)

        # Defaults to false
        opts[:pen_test] ? (http_body[:pen_test] = true) : (http_body[:pen_test] = false)

        # Defaults to false
        opts[:threat_model] ? (http_body[:threat_model] = true) : (http_body[:threat_model] = false)

        # Defaults to false
        opts[:check_list] ? (http_body[:check_list] = true) : (http_body[:check_list] = false)

        # Defaults to Time.now.strftime('%Y-%m-%d')
        opts[:first_contacted] ? (http_body[:first_contacted] = opts[:first_contacted]) : (http_body[:first_contacted] = Time.now.strftime('%Y-%m-%d'))

        # Defaults to Time.now.strftime('%Y-%m-%d')
        opts[:target_start] ? (http_body[:target_start] = opts[:target_start]) : (http_body[:target_start] = Time.now.strftime('%Y-%m-%d'))

        # Defaults to Time.now.strftime('%Y-%m-%d')
        opts[:target_end] ? (http_body[:target_end] = opts[:target_end]) : (http_body[:target_end] = Time.now.strftime('%Y-%m-%d'))

        # Defaults to false
        http_body[:done_testing] = false

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: 'engagements/',
          http_method: :post,
          http_body: http_body
        )

        return response
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # test_list = CSI::Plugins::DefectDojo.test_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   id: 'optional - retrieve single test by id, otherwise return all'
      # )

      public_class_method def self.test_list(opts = {})
        dd_obj = opts[:dd_obj]
        opts[:id] ? (rest_call = "tests/#{opts[:id].to_i}") : (rest_call = 'tests')

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: rest_call
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        test_list = json_response

        return test_list
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # importscan_response = CSI::Plugins::DefectDojo.importscan(
      #   dd_obj: 'required - dd_obj returned from #login_v1 method',
      #   engagement_name: 'required - name of engagement to associate w/ scan',
      #   scan_type: 'required - type of scan importing (see <DEFECTDOJO_URL>/admin/dojo/test_type/ for listing)',
      #   file: 'required - path of scan results file',
      #   lead_username: 'required - username of lead to tie to scan',
      #   tags: 'optional - comma-delimited list of tag names to tie to scan',
      #   minimum_severity: 'optional - minimum finding severity Info||Low||Medium||High||Critical (Defaults to Info)',
      #   scan_date: 'optional - date in which scan was kicked off (defaults to now)',
      #   verified: 'optional - flag finding as verified by a tester (defaults to false)'
      # )

      public_class_method def self.importscan(opts = {})
        http_body = {}

        dd_obj = opts[:dd_obj]

        # HTTP POST body options w/ optional params set to default values
        # Defaults to true
        http_body[:active] = true

        # Ok lets determine the resource_uri for the engagement name
        engagement_name = opts[:engagement_name].to_s.strip.chomp.scrub
        engagement_list = self.engagement_list(dd_obj: dd_obj)
        engagement_by_name_object = engagement_list[:objects].select { |engagement| engagement[:name] == engagement_name }
        # Should only ever return 1 result so we should be good here
        http_body[:engagement] = engagement_by_name_object.first[:resource_uri]

        http_body[:scan_type] = opts[:scan_type].to_s.strip.chomp.scrub

        # Necessary to upload file to remote host
        http_body[:multipart] = true
        http_body[:file] = File.new(opts[:file].to_s.strip.chomp.scrub, 'rb') if File.exist?(opts[:file].to_s.strip.chomp.scrub)

        # Ok lets determine the resource_uri for the lead username
        lead_username = opts[:lead_username].to_s.strip.chomp.scrub
        user_list = self.user_list(dd_obj: dd_obj)
        user_by_username_object = user_list[:objects].select { |user| user[:username] == lead_username }
        # Should only ever return 1 result so we should be good here
        http_body[:lead] = user_by_username_object.first[:resource_uri]

        http_body[:tags] = opts[:tags].to_s.strip.chomp.scrub

        minimum_severity = opts[:minimum_severity].to_s.strip.chomp.scrub.downcase.capitalize
        case minimum_severity
        when '', 'Info', 'Low', 'Medium', 'High', 'Critical'
          # Defaults to 'Info'
          minimum_severity == '' ? (http_body[:minimum_severity] = 'Info') : (http_body[:minimum_severity] = minimum_severity)
        else
          raise "Unknown minimum severity: #{opts[:minimum_severity]}.  Options are Info||Low||Medium||High||Critical'"
        end

        # Defaults to Time.now.strftime('%Y-%m-%d')
        opts[:scan_date] ? (http_body[:scan_date] = opts[:scan_date]) : (http_body[:scan_date] = Time.now.strftime('%Y-%m-%d'))

        # Defaults to false
        opts[:verified] ? (http_body[:verified] = true) : (http_body[:verified] = false)

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: 'importscan/',
          http_method: :post,
          http_body: http_body
        )

        return response
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # reimportscan_response = CSI::Plugins::DefectDojo.reimportscan(
      #   dd_obj: 'required - dd_obj returned from #login_v1 method',
      #   engagement_name: 'required - name of engagement to associate w/ scan',
      #   scan_type: 'required - type of scan importing (see <DEFECTDOJO_URL>/admin/dojo/test_type/ for listing)',
      #   file: 'required - path of scan results file',
      #   tags: 'optional - comma-delimited list of tag names to tie to scan for unique test resource_uri retrival',
      #   test_resource_uri: 'optional - alternative to tag names to know which test to reimport',
      #   minimum_severity: 'optional - minimum finding severity Info||Low||Medium||High||Critical (Defaults to Info)',
      #   scan_date: 'optional - date in which scan was kicked off (defaults to now)',
      #   verified: 'optional - flag finding as verified by a tester (defaults to false)'
      # )

      public_class_method def self.reimportscan(opts = {})
        http_body = {}

        dd_obj = opts[:dd_obj]

        # HTTP POST body options w/ optional params set to default values
        # Defaults to true
        http_body[:active] = true

        # Ok lets determine the resource_uri for the engagement name
        engagement_name = opts[:engagement_name].to_s.strip.chomp.scrub
        engagement_list = self.engagement_list(dd_obj: dd_obj)
        engagement_by_name_object = engagement_list[:objects].select { |engagement| engagement[:name] == engagement_name }
        # Should only ever return 1 result so we should be good here
        engagement_resource_uri = engagement_by_name_object.first[:resource_uri]
        # http_body[:engagement] = engagement_resource_uri

        # TODO: lookup scan_type for test resource_uri since the scan_type should never change
        http_body[:scan_type] = opts[:scan_type].to_s.strip.chomp.scrub

        # Necessary to upload file to remote host
        http_body[:multipart] = true
        http_body[:file] = File.new(opts[:file].to_s.strip.chomp.scrub, 'rb') if File.exist?(opts[:file].to_s.strip.chomp.scrub)

        # Ok lets determine the resource_uri for the test we're looking to remimport
        test_list = self.test_list(dd_obj: dd_obj)
        tests_by_engagement_object = test_list[:objects].select { |test| test[:engagement] == engagement_resource_uri }

        tags = opts[:tags].to_s.strip.chomp.scrub
        # TODO: wait for solution to:
        # https://github.com/DefectDojo/django-DefectDojo/issues/457
        # in order to obtain the unique test resource_uri
        # by searching tags for unique identifier (would be better to have a unique test names)

        http_body[:tags] = tags

        http_body[:test] = opts[:test_resource_uri] if opts[:test_resource_uri]

        minimum_severity = opts[:minimum_severity].to_s.strip.chomp.scrub.downcase.capitalize
        case minimum_severity
        when '', 'Info', 'Low', 'Medium', 'High', 'Critical'
          # Defaults to 'Info'
          minimum_severity == '' ? (http_body[:minimum_severity] = 'Info') : (http_body[:minimum_severity] = minimum_severity)
        else
          raise "Unknown minimum severity: #{opts[:minimum_severity]}.  Options are Info||Low||Medium||High||Critical'"
        end

        # Defaults to Time.now.strftime('%Y-%m-%d')
        opts[:scan_date] ? (http_body[:scan_date] = opts[:scan_date]) : (http_body[:scan_date] = Time.now.strftime('%Y/%m/%d'))

        # Defaults to false
        opts[:verified] ? (http_body[:verified] = true) : (http_body[:verified] = false)

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: 'reimportscan/',
          http_method: :post,
          http_body: http_body
        )

        return response
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # finding_list = CSI::Plugins::DefectDojo.finding_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   id: 'optional - retrieve single finding by id, otherwise return all'
      # )

      public_class_method def self.finding_list(opts = {})
        dd_obj = opts[:dd_obj]
        opts[:id] ? (rest_call = "findings/#{opts[:id].to_i}") : (rest_call = 'findings')

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: rest_call
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        finding_list = json_response

        return finding_list
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # user_list = CSI::Plugins::DefectDojo.user_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   id: 'optional - retrieve single user by id, otherwise return all'
      # )

      public_class_method def self.user_list(opts = {})
        dd_obj = opts[:dd_obj]
        opts[:id] ? (rest_call = "users/#{opts[:id].to_i}") : (rest_call = 'users')

        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: rest_call
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        finding_list = json_response

        return finding_list
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::DefectDojo.logout(
      #   dd_obj: 'required dd_obj returned from #login_v1 or #login_v2 method'
      # )

      public_class_method def self.logout(opts = {})
        dd_obj = opts[:dd_obj]
        @@logger.info('Logging out...')
        # TODO: Terminate Session if Possible via API Call
        dd_obj = nil
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          dd_obj = #{self}.login_v1(
            url: 'required - url of DefectDojo Server',
            username: 'required - username to AuthN w/ api v1)',
            api_key: 'optional - defect dojo api key (will prompt if nil)',
            debug: 'optional - proxy all traffic through http://127.0.0.1:8080 for debug (defaults to false)'
          )

          dd_obj = #{self}.login_v2(
            url: 'required - url of DefectDojo Server',
            username: 'required - username to AuthN w/ api v2)',
            password: 'optional - defect dojo api key (will prompt if nil)'
          )

          product_list = #{self}.product_list(
            dd_obj: 'required dd_obj returned from #login_v1 method',
            id: 'optional - retrieve single product by id, otherwise return all'
          )

          engagement_list = #{self}.engagement_list(
            dd_obj: 'required dd_obj returned from #login_v1 method',
            id: 'optional - retrieve single engagement by id, otherwise return all'
          )

          engagement_create_response = #{self}.engagement_create(
            dd_obj: 'required - dd_obj returned from #login_v1 method',
            name: 'required - name of the engagement',
            description: 'optional - description of engagement',
            engagement_type: 'optional - type of engagement Interactive||CI/CD (defaults to CI/CD)',
            status: 'optional - status of the engagement In Progress || On Hold (defaults to In Progress)',
            lead_username: 'required - username of lead to tie to engagement',
            product_name: 'required - product name in which to create engagement',
            test_strategy: 'required - URL of test strategy documentation (e.g. OWASP ASVS URL)',
            orchestration_engine: 'optional - name of orchestration engine tied to CI/CD engagement',
            build_server: 'optional - name of build server tied to CI/CD engagement',
            scm_server: 'optional - name of SCM server tied to CI/CD engagement',
            api_test: 'optional - boolean to set an engagement as an api assessment (defaults to false)',
            pen_test: 'optional - boolean to set an engagement as a manual penetration test (defaults to false)',
            threat_model: 'optional - boolean to set an engagement as a threat model (defaults to false)',
            check_list: 'optional - boolean to set an engagement as a checkbox assessment (defaults to false)',
            first_contacted: 'optional - date of engagement request e.g. 2018-06-18 (Defaults to current day)',
            target_start: 'optional - date to start enagement e.g. 2018-06-19 (Defaults to current day)',
            target_end: 'optional - date of engagement completion e.g. 2018-06-20 (Defaults to current day)'
          )

          test_list = #{self}.test_list(
            dd_obj: 'required dd_obj returned from #login_v1 method',
            id: 'optional - retrieve single test by id, otherwise return all'
          )

          importscan_response = #{self}.importscan(
            dd_obj: 'required - dd_obj returned from #login_v1 method',
            engagement_name: 'required - name of engagement to associate w/ scan',
            scan_type: 'required - type of scan importing (see <DEFECTDOJO_URL>/admin/dojo/test_type/ for listing)',
            file: 'required - path of scan results file',
            lead_username: 'required - username of lead to tie to scan',
            tags: 'optional - comma-delimited list of tag names to tie to scan',
            minimum_severity: 'optional - minimum finding severity Info||Low||Medium||High||Critical (Defaults to Info)',
            scan_date: 'optional - date in which scan was kicked off (defaults to now)',
            verified: 'optional - flag finding as verified by a tester (defaults to false)'
          )

          reimportscan_response = #{self}.reimportscan(
            dd_obj: 'required - dd_obj returned from #login_v1 method',
            engagement_name: 'required - name of engagement to associate w/ scan',
            scan_type: 'required - type of scan importing (see <DEFECTDOJO_URL>/admin/dojo/test_type/ for listing)',
            file: 'required - path of scan results file',
            tags: 'optional - comma-delimited list of tag names to tie to scan for unique test resource_uri retrival',
            test_resource_uri: 'optional - alternative to tag names to know which test to reimport',
            minimum_severity: 'optional - minimum finding severity Info||Low||Medium||High||Critical (Defaults to Info)',
            scan_date: 'optional - date in which scan was kicked off (defaults to now)',
            verified: 'optional - flag finding as verified by a tester (defaults to false)'
          )

          finding_list = #{self}.finding_list(
            dd_obj: 'required dd_obj returned from #login_v1 method',
            id: 'optional - retrieve single finding by id, otherwise return all'
          )

          user_list = #{self}.user_list(
            dd_obj: 'required dd_obj returned from #login_v1 method',
            id: 'optional - retrieve single user by id, otherwise return all'
          )

          #{self}.logout(
            dd_obj: 'required dd_obj returned from #login_v1 or #login_v2 method'
          )

          #{self}.authors
        "
      end
    end
  end
end
