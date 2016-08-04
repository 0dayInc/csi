require 'json'
require 'owasp_zap'
include OwaspZap

module CSI
  module Plugins
    # This plugin converts images to readable text
    module OwaspZapIt
      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.start(
      #   :target => 'required - target URL to test',
      #   :headless => 'optional - run zap headless if set to true'
      # )
      public
      def self.start(opts={})
        target = opts[:target].to_s.scrub.strip.chomp

        zab_obj = Zap.new(:target => target)

        if opts[:zap_bin_path]
          zap_bin_path = opts[:zap_bin_path].to_s.scrub.strip.chomp if File.exists?(opts[:zap_bin_path].to_s.scrub.strip.chomp)
        else
          underlying_os = CSI::Plugins::DetectOS.type

          case underlying_os
            when :osx
              zab_obj.zap_bin = '/Applications/OWASP\ ZAP.app/Contents/Java/zap.sh'
          else
            raise "ERROR: zap.sh not found for #{underlying_os}. Please pass the :zap_bin_path parameter to this method for proper execution"
            exit 1
          end
        end


        if headless
          zap_obj.start(:daemon => true)
        else
          zap_obj.start
        end

        return zap_obj
      end

      # Supported Method Parameters::
      # CSI::Plugins::OwaspZapIt.close(
      #   :zap_obj => 'required - zap_obj returned from #open method'
      # )
      public
      def self.stop(opts={})
        zap_obj = opts[:zap_obj]
        
        begin
          zap_obj.shutdown
        rescue => e
          raise e.message
          return -1
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
          zap_obj = #{self}.start(
            :target => 'required - target URL to test',
            :headless => 'optional - run zap headless if set to true'
          )

          #{self}.close(
            :zap_obj => 'required - zap_obj returned from #open method'
          )

          #{self}.authors
        }
      end
    end
  end
end
