# frozen_string_literal: true

require 'jenkins_api_client'

module CSI
  module Plugins
    # This plugin is used to interact w/ the Jenkins API and can be
    # used to carry out tasks when certain events occur w/in Jenkins.
    module Jenkins
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.connect(
      #   jenkins_ip: 'required host/ip of Jenkins Server',
      #   port: 'optional tcp port (defaults to 8080),
      #   username: 'optional username (functionality will be limited if ommitted)',
      #   password: 'optional password (functionality will be limited if ommitted)'
      #   identity_file: 'optional ssh private key path to AuthN w/ Jenkins PREFERRED over username/password',
      #   ssl: 'optional connect over TLS (defaults to true)
      # )

      public

      def self.connect(opts = {})
        jenkins_ip = opts[:jenkins_ip]
        port = if opts[:port]
                 opts[:port].to_i
               else
                 8080
               end
        username = opts[:username].to_s.scrub
        base_jenkins_api_uri = "https://#{jenkins_ip}/ase/services".to_s.scrub
        password = opts[:password].to_s.scrub
        identity_file = opts[:identity_file].to_s.scrub
        ssl_bool = if opts[:ssl] == true
                     opts[:ssl]
                   else
                     false
                   end

        @@logger.info("Logging into Jenkins Server: #{jenkins_ip}")
        if username == '' && password == ''
          if identity_file == ''
            jenkins_obj = JenkinsApi::Client.new(
              server_ip: jenkins_ip,
              server_port: port,
              follow_redirects: true,
              ssl: ssl_bool
            )
          else
            jenkins_obj = JenkinsApi::Client.new(
              server_ip: jenkins_ip,
              server_port: port,
              identity_file: identity_file,
              follow_redirects: true,
              ssl: ssl_bool
            )
          end
        else
          password = CSI::Plugins::AuthenticationHelper.mask_password if password == ''
          jenkins_obj = JenkinsApi::Client.new(
            server_ip: jenkins_ip,
            server_port: port,
            username: username,
            password: password,
            follow_redirects: true,
            ssl: ssl_bool
          )
        end
        jenkins_obj.system.wait_for_ready
        return jenkins_obj
      rescue => e
        return e.message
      end

      # CSI::Plugins::Jenkins.create_user(
      #   jenkins_obj: 'required - jenkins_obj returned from login method',
      #   username: 'required - user to create',
      #   password: 'required - password for new user'
      #   fullname: 'required - full name of new user'
      #   email: 'required - email address of new user'
      # )

      public

      def self.create_user(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        username = opts[:username].to_s.scrub
        password = opts[:password].to_s.scrub
        password = CSI::Plugins::AuthenticationHelper.mask_password if password == ''
        fullname = opts[:fullname].to_s.scrub
        email = opts[:email].to_s.scrub

        post_body = {
          'username' => username,
          'password1' => password,
          'password2' => password,
          'fullname' => fullname,
          'email' => email,
          'json' => {
            'username' => username,
            'password1' => password,
            'password2' => password,
            'fullname' => fullname,
            'email' => email
          }.to_json
        }

        @@logger.info("Creating #{username}...")

        resp = jenkins_obj.api_post_request(
          '/securityRealm/createAccountByAdmin',
          post_body
        )

        if resp == '302'
          return true # Successful creation occurred
        else
          return false # Something unexpected happened
        end
      # rescue JenkinsApi::Exceptions::UserAlreadyExists => e
      #   @@logger.warn("Jenkins view: #{view_name} already exists")
      #   return e.class
      rescue => e
        puts e.message
        puts e.backtrace
        puts e.class
      end

      # CSI::Plugins::Jenkins.create_ssh_credential(
      #   jenkins_obj: 'required - jenkins_obj returned from login method',
      #   username: 'required - username for new credential'
      #   private_key_path: 'required - path of private ssh key for new credential'
      #   key_passphrase: 'optional - private key passphrase for new credential'
      #   description: 'optional - description of new credential'
      #   domain: 'optional - defaults to GLOBAL',
      #   scope: 'optional - GLOBAL or SYSTEM (defaults to GLOBAL)'
      # )

      public

      def self.create_ssh_credential(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        username = opts[:username].to_s.scrub
        private_key_path = opts[:private_key_path].to_s.strip.chomp.scrub if File.exist?(opts[:private_key_path].to_s.strip.chomp.scrub)
        key_passphrase = opts[:key_passphrase].to_s.scrub
        description = opts[:description].to_s.scrub

        if opts[:domain].to_s.strip.chomp.scrub == 'GLOBAL' or opts[:domain].nil?
          uri_path = '/credentials/store/system/domain/_/createCredentials'
        else
          domain = opts[:domain].to_s.strip.chomp.scrub
          uri_path = "/credentials/store/system/domain/#{domain}/createCredentials"
        end

        if opts[:scope].to_s.strip.chomp.scrub.casecmp('SYSTEM')
          scope = 'SYSTEM'
        else
          scope = 'GLOBAL'
        end

        post_body = {
          'scope' => scope,
          'username' => username,
          'private_key' => private_key_path,
          'passphrase' => key_passphrase,
          'description' => description,
          'json' => {
            'credentials' => {
              'scope' => scope,
              'username' => username,
              'privateKeySource' => {
                'value' => '1', 
                'privateKeyFile' => private_key_path,
                'stapler-class' => 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$FileOnMasterPrivateKeySource'
              },
              'passphrase' => key_passphrase,
              'description' => description,
              'stapler-class' => 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey',
              '$class' => 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey'
            }
          }.to_json
        }

        resp = jenkins_obj.api_post_request(
          uri_path,
          post_body
        )

        if resp == '302'
          return true # Successful creation occurred
        else
          return false # Something unexpected happened
        end
      rescue => e
        puts e.message
        puts e.backtrace
        puts e.class
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.get_all_job_git_repos(
      #   jenkins_obj: 'required jenkins_obj returned from login method'
      # )

      public

      def self.get_all_job_git_repos(opts = {})
        jenkins_obj = opts[:jenkins_obj]

        @@logger.info('Retrieving a List of Git Repos from Every Job...')

        git_repo_arr = []

        jenkins_obj.job.list_all_with_details.each do |job|
          this_config = Nokogiri::XML(jenkins_obj.job.get_config(job['name']))
          this_git_repo = this_config.xpath('//scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url').text
          this_git_branch = this_config.xpath('//scm/branches/hudson.plugins.git.BranchSpec/name').text
          next if this_git_repo == ''
          # Obtain all jobs' git repos
          job_git_repo = {}
          job_git_repo[:name] = job['name']
          job_git_repo[:url] = job['url']
          job_git_repo[:job_state] = job['color']
          job_git_repo[:git_repo] = this_git_repo
          job_git_repo[:git_branch] = this_git_branch
          job_git_repo[:config_xml_response] = this_config
          git_repo_arr.push(job_git_repo)
        end

        git_repo_arr
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.list_nested_jobs(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   view_path: 'required view path to list jobs'
      # )

      public

      def self.list_nested_jobs(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        view_path = opts[:view_path].to_s.scrub
        nested_view_resp = jenkins_obj.api_get_request(view_path)
        nested_jobs_arr = nested_view_resp['jobs']

        nested_jobs_arr
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.list_nested_views(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   view_path: 'required view path list sub-views'
      # )

      public

      def self.list_nested_views(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        view_path = opts[:view_path].to_s.scrub
        nested_view_resp = jenkins_obj.api_get_request(view_path)
        nested_views_arr = nested_view_resp['views']

        nested_views_arr
      rescue => e
        raise e.message
      end

      # CSI::Plugins::Jenkins.create_nested_view(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   view_path: 'required view path create',
      #   create_in_view_path: 'optional creates nested view within an existing nested view, defaults to / views'
      # )

      public

      def self.create_nested_view(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        view_name = opts[:view_name].to_s.scrub
        create_in_view_path = opts[:create_in_view_path].to_s.scrub
        # TODO: pass parameter for modes and use case statement to build dynamically post_body
        # mode = 'hudson.plugins.nested_view.NestedView' # Requires Jenkins Nested View Plugin to Work Properly
        mode = 'hudson.model.ListView'

        post_body = {
          'name' => view_name,
          'mode' => mode,
          'json' => {
            'name' => view_name,
            'mode' => mode
          }.to_json
        }

        if create_in_view_path == '' || create_in_view_path == '/'
          @@logger.info('Creating Nested View in /...')

          resp = jenkins_obj.api_post_request(
            '/createView',
            post_body
          )
        else
          @@logger.info("Creating Nested View in #{create_in_view_path}...")

          # Example view_path would be '/view/Projects/PROJECT_NAME/view/RELEASES'
          # This is taken out of the Jenkins URI when residing in the view in which
          # you want to create your view...simply drop the domain name.
          resp = jenkins_obj.api_post_request(
            "#{create_in_view_path}/createView",
            post_body
          )
        end
        if resp == '302'
          return true # Successful creation occurred
        else
          return false # Something unexpected happened
        end
      rescue JenkinsApi::Exceptions::ViewAlreadyExists => e
        @@logger.warn("Jenkins view: #{view_name} already exists")
        return e.class
      rescue => e
        puts e.message
        puts e.backtrace
        puts e.class
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.add_job_to_nested_view(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   view_path: 'required view path associate job',
      #   job_name: 'required view path attach to a view',
      # )
      def self.add_job_to_nested_view(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        view_path = opts[:view_path].to_s.scrub
        job_name = opts[:job_name].to_s.scrub
        resp = jenkins_obj.api_post_request("#{view_path}/addJobToView?name=#{job_name}")
        resp
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.copy_job_no_fail_on_exist(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   existing_job_name: 'required existing job to copt to new job',
      #   new_job_name: 'required name of new job'
      # )

      public

      def self.copy_job_no_fail_on_exist(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        existing_job_name = opts[:existing_job_name]
        new_job_name = opts[:new_job_name]

        copy_job_resp = jenkins_obj.job.copy(existing_job_name, new_job_name)
      rescue JenkinsApi::Exceptions::JobAlreadyExists => e
        @@logger.warn("Jenkins job: #{new_job_name} already exists")
        return e.class
      rescue => e
        puts e.message
        puts e.backtrace
        puts e.class
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.disable_jobs_by_regex(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   regex: 'required regex pattern for matching jobs to disable e.g. :regex => "^M[0-9]"',
      # )

      public

      def self.disable_jobs_by_regex(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        regex = opts[:regex].to_s.scrub

        jenkins_obj.job.list_all_with_details.each do |job|
          job_name = job['name']
          if job_name.match?(/#{regex}/)
            @@logger.info("Disabling #{job_name}")
            jenkins_obj.job.disable(job_name)
          end
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.delete_jobs_by_regex(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      #   regex: 'required regex pattern for matching jobs to disable e.g. :regex => "^M[0-9]"',
      # )

      public

      def self.delete_jobs_by_regex(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        regex = opts[:regex].to_s.scrub

        jenkins_obj.job.list_all_with_details.each do |job|
          job_name = job['name']
          if job_name.match?(/#{regex}/)
            @@logger.info("Deleting #{job_name}")
            jenkins_obj.job.delete(job_name)
          end
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.clear_build_queue(
      #   jenkins_obj: 'required jenkins_obj returned from login method',
      # )

      public

      def self.clear_build_queue(opts = {})
        jenkins_obj = opts[:jenkins_obj]

        jenkins_obj.queue.list.each do |job_name|
          @@logger.info("Clearing #{job_name} Build from Queue")
          jenkins_obj.job.stop_build(job_name)
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Jenkins.disconnect(
      #   jenkins_obj: 'required jenkins_obj returned from login method'
      # )

      public

      def self.disconnect(opts = {})
        jenkins_obj = opts[:jenkins_obj]
        @@logger.info('Disconnecting from Jenkins...')
        jenkins_obj = nil
        'complete'
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
        puts %{USAGE:
          jenkins_obj = #{self}.connect(
            jenkins_ip: 'required host/ip of Jenkins Server',
            port: 'optional tcp port (defaults to 8080),
            username: 'optional username (functionality will be limited if ommitted)',
            password: 'optional password (functionality will be limited if ommitted)',
            identity_file: 'optional ssh private key path to AuthN w/ Jenkins PREFERRED over username/password',
            ssl: 'optional connect over TLS (defaults to true)
          )
          puts jenkins_obj.public_methods

          #{self}.create_user(
            jenkins_obj: 'required - jenkins_obj returned from login method',
            username: 'required - user to create',
            password: 'optional - password for new user (will prompt if nil)'
            fullname: 'required - full name of new user'
            email: 'required - email address of new user'
          )

          #{self}.create_ssh_credential(
            jenkins_obj: 'required - jenkins_obj returned from login method',
            username: 'required - username for new credential'
            private_key_path: 'required - path of private ssh key for new credential'
            key_passphrase: 'optional - private key passphrase for new credential'
            description: 'optional - description of new credential'
            domain: 'optional - defaults to GLOBAL',
            scope: 'optional - GLOBAL or SYSTEM (defaults to GLOBAL)'
          )

          git_repo_arr = #{self}.get_all_job_git_repos(
            jenkins_obj: 'required jenkins_obj returned from connect method'
          )

          git_repo_branches = #{self}.get_all_git_repo_branches_by_commit_date(
            jenkins_obj: 'required jenkins_obj returned from login method',
            job_name: 'required jenkins job name',
            git_url: 'required git url for git_repo'
          )

          nested_jobs_arr = #{self}.list_nested_jobs(
            jenkins_obj: 'required jenkins_obj returned from login method',
            view_path: 'required view path list jobs'
          )

          nested_views_arr = #{self}.list_nested_views(
            jenkins_obj: 'required jenkins_obj returned from login method',
            view_path: 'required view path list sub-views'
          )

          view_created_bool = #{self}.create_nested_view(
            jenkins_obj: 'required jenkins_obj returned from login method',
            view_path: 'required view path create',
            create_in_view_path: 'optional creates nested view within an existing nested view, defaults to / views'
          )

          add_job_to_nested_view_resp = #{self}.add_job_to_nested_view(
            jenkins_obj: 'required jenkins_obj returned from login method',
            view_path: 'required view path associate job',
            job_name: 'required view path attach to a view',
          )

          copy_job_resp = #{self}.copy_job_no_fail_on_exist(
            jenkins_obj: 'required jenkins_obj returned from login method',
            existing_job_name: 'required existing job to copt to new job',
            new_job_name: 'required name of new job'
          )

          #{self}.disable_jobs_by_regex(
            jenkins_obj: 'required jenkins_obj returned from login method',
            regex: 'required regex pattern for matching jobs to disable e.g. :regex => "^M[0-9]"',
          )

          #{self}.delete_job_by_regex(
            jenkins_obj: 'required jenkins_obj returned from login method',
            regex: 'required regex pattern for matching jobs to disable e.g. :regex => "^M[0-9]"',
          )

          #{self}.clear_build_queue(
            jenkins_obj: 'required jenkins_obj returned from login method',
          )

          #{self}.disconnect(
            jenkins_obj: 'required jenkins_obj returned from connect method'
          )

          #{self}.authors
        }
      end
    end
  end
end
