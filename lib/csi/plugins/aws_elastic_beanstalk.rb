require 'fog'

module CSI
  module Plugins
    # This plugin was initially created to support retrieval of Elastic Beanstalk resources created w/in AWS.
    module AWSElasticBeanstalk
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AWSElasticBeanstalk.connect(
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
          @@logger.info("Connecting to AWS ElasticBeanstalk...")
          if sts_session_token == ""
            eb_obj = Fog::AWS::ElasticBeanstalk.new(
              :region => region,
              :aws_access_key_id => access_key_id,
              :aws_secret_access_key => secret_access_key
            )
          else
            eb_obj = Fog::AWS::ElasticBeanstalk.new(
              :region => region,
              :aws_access_key_id => access_key_id,
              :aws_secret_access_key => secret_access_key,
              :aws_session_token => sts_session_token
            )
          end
          @@logger.info("complete.\n")

          return eb_obj  
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSElasticBeanstalk.environments(
      #   :eb_obj => 'required - eb_obj returned from #connect method'
      # )
      public
      def self.environments(opts = {})
        eb_obj = opts[:eb_obj]
        return eb_obj.describe_environments.data[:body]["DescribeEnvironmentsResult"]["Environments"]
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSElasticBeanstalk.disconnect(
      #   :eb_obj => 'required - eb_obj returned from #connect method'
      # )
      public
      def self.disconnect(opts = {})
        eb_obj = opts[:eb_obj]
        @@logger.info("Disconnecting...")
        eb_obj = nil
        @@logger.info("complete.\n")

        return eb_obj
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
          eb_obj = #{self}.connect(
            :region => 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
            :access_key_id => 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
            :secret_access_key => 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
            :sts_session_token => 'optional - Temporary token returned by STS client for best privacy'
          )

          #{self}.environments(
            :eb_obj => 'required - eb_obj returned from #connect method'
          )

          #{self}.disconnect(
            :eb_obj => 'required - eb_obj returned from #connect method'
          )

          #{self}.authors
        }
      end
    end
  end
end
