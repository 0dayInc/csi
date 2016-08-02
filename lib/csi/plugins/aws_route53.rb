require 'fog'

module CSI
  module Plugins
    # This plugin was initially created to support retrieval of Route53 resources created w/in AWS.
    module AWSRoute53
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AWSRoute53.connect(
      #   :access_key_id => 'required - AWS Access Key ID',
      #   :secret_access_key => 'required - AWS Secret Access Key',
      #   :sts_session_token => 'optional - Temporary token returned by STS client for best privacy'
      # )
      public
      def self.connect(opts = {})
        access_key_id = opts[:access_key_id].to_s.scrub.chomp.strip
        secret_access_key = opts[:secret_access_key].to_s.scrub.chomp.strip
        sts_session_token = opts[:sts_session_token].to_s.scrub.chomp.strip

        begin
          @@logger.info("Logging into AWS Route53...")
          if sts_session_token == ""
            r53_obj = Fog::DNS.new(
              :provider => 'AWS', 
              :aws_access_key_id => access_key_id,
              :aws_secret_access_key => secret_access_key
            ) 
          else
            r53_obj = Fog::DNS.new(
              :provider => 'AWS', 
              :aws_access_key_id => access_key_id,
              :aws_secret_access_key => secret_access_key,
              :aws_session_token => sts_session_token
            ) 
          end
          @@logger.info("complete.\n")

          return r53_obj  
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSRoute53.zones(
      #   :r53_obj => 'required - r53_obj returned from #connect method'
      # )
      public
      def self.zones(opts = {})
        r53_obj = opts[:r53_obj]
        @@logger.info("Retrieving a List of Zones from AWS Route53...")
        r53_zones = r53_obj.zones[0]

        r53_zones_hash = {}
        r53_zones_hash[:id] = r53_zones.id
        r53_zones_hash[:caller_reference] = r53_zones.caller_reference
        r53_zones_hash[:change_info] = r53_zones.change_info
        r53_zones_hash[:description] = r53_zones.description
        r53_zones_hash[:domain] = r53_zones.domain
        r53_zones_hash[:nameservers] = r53_zones.nameservers

        return r53_zones_hash
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSRoute53.records(
      #   :r53_obj => 'required - r53_obj returned from #connect method'
      #   :zone_id => 'required - zone id returned from #zones method'
      # )
      public
      def self.records(opts = {})
        r53_obj = opts[:r53_obj]
        zone_id = opts[:zone_id].to_s.scrub.strip.chomp
        @@logger.info("Retrieving a List of Records from AWS Route53...")
        r53_records = r53_obj.list_resource_record_sets(zone_id).data
        return r53_records
      end

      # Supported Method Parameters::
      # CSI::Plugins::AWSRoute53.disconnect(
      #   :r53_obj => 'required - r53_obj returned from #connect method'
      # )
      public
      def self.disconnect(opts = {})
        r53_obj = opts[:r53_obj]
        @@logger.info("Disconnecting from AWS Route53...")
        r53_obj = nil
        @@logger.info("complete.\n")
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
          r53_obj = #{self}.connect(
            :access_key_id => 'required - AWS Access Key ID',
            :secret_access_key => 'required - AWS Secret Access Key',
            :sts_session_token => 'optional - Temporary token returned by STS client for best privacy'
          )

          r53_zones = #{self}.zones(
            :r53_obj => 'required - r53_obj returned from #connect method'
          )

          r53_records = #{self}.records(
            :r53_obj => 'required - r53_obj returned from #connect method'
            :zone_id => 'required - zone id returned from #zones method'
          )

          #{self}.disconnect(
            :r53_obj => 'required - r53_obj returned from #connect method'
          )

          #{self}.authors
        }
      end
    end
  end
end
