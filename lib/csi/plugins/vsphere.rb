# frozen_string_literal: true

require 'rbvmomi'

module CSI
  module Plugins
    # This plugin is used for interacting w/ HackerOne's REST API using
    # the 'rest' browser type of CSI::Plugins::TransparentBrowser.
    module Vsphere
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # vsphere_obj = CSI::Plugins::Vsphere.login(
      #   host: 'required - vsphere host or ip',
      #   username: 'required - username',
      #   password: 'optional - password (will prompt if nil)'
      # )

      public

      def self.login(opts = {})
        host = opts[:host].to_s.scrub
        username = opts[:username].to_s.scrub
        password = if opts[:password].nil?
                  CSI::Plugins::AuthenticationHelper.mask_password
                else
                  opts[:password].to_s.scrub
                end

        @@logger.info("Logging into vSphere: #{host}")
        vsphere_obj = RbVmomi::VIM.connect(
          host: host,
          user: username,
          password: password
        )
        return vsphere_obj
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::HackerOne.logout(
      #   vsphere_obj: 'required vsphere_obj returned from #login method'
      # )

      public

      def self.logout(opts = {})
        vsphere_obj = opts[:vsphere_obj]
        @@logger.info('Logging out...')
        vsphere_obj = nil
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
          vsphere_obj = #{self}.login(
            host: 'required - vsphere host or ip',
            username: 'required - username',
            password: 'optional - password (will prompt if nil)'
          )

          vsphere_obj = #{self}.logout(
            vsphere_obj: 'required vsphere_obj returned from #login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
