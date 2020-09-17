# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin is used for interacting w/ OpenVAS using OMP (OpenVAS Management Protocol).
    module OpenVASVulnScan
      @@logger = CSI::Plugins::CSILogger.create
      @@omp_bin = '/usr/local/bin/omp'

      # Supported Method Parameters::
      # CSI::Plugins::OpenVASVulnScan.login(
      #   openvas_ip: 'required host/ip of OpenVAS Management Daemon(openvasmd)',
      #   openvas_port: 'optional port of openvasmd (defaults to 9390)'
      #   username: 'required username',
      #   password: 'optional password (will prompt if nil)'
      # )

      public_class_method def self.login(opts = {})
        openvas_ip = opts[:openvas_ip].to_s.scrub
        openvas_port = if opts[:openvas_port].nil?
                         9390
                       else
                         opts[:openvas_port].to_i
                       end
        username = opts[:username].to_s.scrub

        password = if opts[:password].nil?
                     CSI::Plugins::AuthenticationHelper.mask_password
                   else
                     opts[:password].to_s.scrub
                   end

        openvas_obj = {}
        openvas_obj[:username] = username
        openvas_obj[:password] = password
        @@logger.info(`#{@@omp_bin} -h #{openvas_ip} -p #{openvas_port} -u #{username} -w #{password} --xml="<authenticate><credentials><username>#{username}</username><password>#{password}</password></credentials></authenticate>"`)
        openvas_obj
      rescue StandardError => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::OpenVASVulnScan.logout(
      #   openvas_obj: 'required openvas_obj returned from login method'
      # )

      public_class_method def self.logout(opts = {})
        openvas_obj = opts[:openvas_obj]

        openvas_obj = nil
        @@logger.info('logged out')
      rescue StandardError => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          openvas_obj = #{self}.login(
            openvas_ip: 'required host/ip of OpenVAS Management Daemon(openvasmd)',
            openvas_port: 'optional port of openvasmd (defaults to 9390)'
            username: 'required username',
            password: 'optional password (will prompt if nil)'
          )

          #{self}.logout(
            openvas_obj: 'required openvas_obj returned from login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
