# frozen_string_literal: true
require 'aws-sdk'

module CSI
  module AWS
    # This module provides a client for making API requests to AWS IoT Data Plane.
    module IoTDataPlane
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::AWS::IoTDataPlane.connect(
      #   region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
      #   access_key_id: 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
      #   secret_access_key: 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
      #   sts_session_token: 'optional - Temporary token returned by STS client for best privacy'
      # )

      public

      def self.connect(opts = {})
        region = opts[:region].to_s.scrub.chomp.strip
        access_key_id = opts[:access_key_id].to_s.scrub.chomp.strip
        secret_access_key = opts[:secret_access_key].to_s.scrub.chomp.strip
        sts_session_token = opts[:sts_session_token].to_s.scrub.chomp.strip

        begin
          @@logger.info('Connecting to AWS IoTDataPlane...')
          if sts_session_token == ''
            iot_data_plane_obj = Aws::IoTDataPlane::Client.new(
              region: region,
              access_key_id: access_key_id,
              secret_access_key: secret_access_key
            )
          else
            iot_data_plane_obj = Aws::IoTDataPlane::Client.new(
              region: region,
              access_key_id: access_key_id,
              secret_access_key: secret_access_key,
              session_token: sts_session_token
            )
          end
          @@logger.info("complete.\n")

          return iot_data_plane_obj
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::AWS::IoTDataPlane.disconnect(
      #   iot_data_plane_obj: 'required - iot_data_plane_obj returned from #connect method'
      # )

      public

      def self.disconnect(opts = {})
        iot_data_plane_obj = opts[:iot_data_plane_obj]
        @@logger.info('Disconnecting...')
        iot_data_plane_obj = nil
        @@logger.info("complete.\n")

        iot_data_plane_obj
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
          iot_data_plane_obj = #{self}.connect(
            region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
            access_key_id: 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
            secret_access_key: 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
            sts_session_token: 'optional - Temporary token returned by STS client for best privacy'
          )
          puts iot_data_plane_obj.public_methods

          #{self}.disconnect(
            iot_data_plane_obj: 'required - iot_data_plane_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
