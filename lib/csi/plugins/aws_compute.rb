require 'aws-sdk'

module CSI
  module Plugins
    # This plugin was initially created to support retrieval of Compute resources created w/in AWS.
    module AWSCompute
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.connect(
      #   :region => 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
      #   :access_key_id => 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
      #   :secret_access_key => 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
      #   :sts_session_token => 'optional - Temporary token returned by STS client for best privacy'
      # )
      public
      def self.connect(opts = {})
        region = opts[:region].to_s.scrub.chomp.strip
        access_key_id = opts[:access_key_id].to_s.scrub.chomp.strip
        secret_access_key = opts[:secret_access_key].to_s.scrub.chomp.strip
        sts_session_token = opts[:sts_session_token].to_s.scrub.chomp.strip

        begin
          @@logger.info("Connecting to AWS Compute...")
          if sts_session_token == ""
            compute_obj = Aws::EC2::Client.new(
              :region => region,
              :access_key_id => access_key_id,
              :secret_access_key => secret_access_key
            )
          else
            compute_obj = Fog::Compute::AWS.new(
              :region => region,
              :access_key_id => access_key_id,
              :secret_access_key => secret_access_key,
              :session_token => sts_session_token
            )
          end
          @@logger.info("complete.\n")

          return compute_obj  
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.ec2_instances(
      #   :compute_obj => 'required - compute_obj returned from #connect method'
      # )
      public
      def self.ec2_instances(opts = {})
        compute_obj = opts[:compute_obj]
        return compute_obj.describe_instances.data[:body]["reservationSet"]
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.elastic_block_stores(
      #   :compute_obj => 'required - compute_obj returned from #connect method'
      # )
      public
      def self.elastic_block_stores(opts = {})
        compute_obj = opts[:compute_obj]
        return compute_obj.describe_volumes.data[:body]["volumeSet"]
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.regions(
      #   :compute_obj => 'required - compute_obj returned from #connect method'
      # )
      public
      def self.regions(opts = {})
        compute_obj = opts[:compute_obj]
        return compute_obj.describe_regions.data[:body]["regionInfo"]
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.security_groups(
      #   :compute_obj => 'required - compute_obj returned from #connect method'
      # )
      public
      def self.security_groups(opts = {})
        compute_obj = opts[:compute_obj]
        return compute_obj.describe_security_groups.data[:body]["securityGroupInfo"]
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSCompute.disconnect(
      #   :compute_obj => 'required - compute_obj returned from #connect method'
      # )
      public
      def self.disconnect(opts = {})
        compute_obj = opts[:compute_obj]
        @@logger.info("Disconnecting...")
        compute_obj = nil
        @@logger.info("complete.\n")

        return compute_obj
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
          compute_obj = #{self}.connect(
            :region => 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
            :access_key_id => 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
            :secret_access_key => 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
            :sts_session_token => 'optional - Temporary token returned by STS client for best privacy'
          )

          #{self}.ec2_instances(
            :compute_obj => 'required - compute_obj returned from #connect method'
          )

          #{self}.elastic_block_stores(
            :compute_obj => 'required - compute_obj returned from #connect method'
          )

          #{self}.regions(
            :compute_obj => 'required - compute_obj returned from #connect method'
          )

          #{self}.security_groups(
            :compute_obj => 'required - compute_obj returned from #connect method'
          )

          #{self}.disconnect(
            :compute_obj => 'required - compute_obj returned from #connect method'
          )

          #{self}.authors
        }
      end
    end
  end
end
