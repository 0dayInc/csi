require 'yaml'
module CSI
  module Plugins
    # Used to encrypt/decrypt configuration files leveraging AES256
    # (ansible-vault utility wrapper)
    module AnsibleVault
      @@logger = CSI::Plugins::CSILogger.create()

      # Supported Method Parameters::
      # CSI::Plugins::AnsibleVault.encrypt(
      #   :yaml_config => 'required - yaml config to encrypt',
      #   :vpassfile => 'required - path to anisble-vault pass file'
      # )
      public
      def self.encrypt(opts={})
        yaml_config = opts[:yaml_config].to_s.scrub if File.exists?(opts[:yaml_config].to_s.scrub)
        vpassfile = opts[:vpassfile].to_s.scrub if File.exists?(opts[:vpassfile].to_s.scrub)

        begin
          vault_cmd_resp = `sudo ansible-vault encrypt #{yaml_config} --vault-password-file #{vpassfile}` 

          return vault_cmd_resp
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::AnsibleVault.decrypt(
      #   :yaml_config => 'required - yaml config to decrypt',
      #   :vpassfile => 'required - path to anisble-vault pass file'
      # )
      public
      def self.decrypt(opts={})
        yaml_config = opts[:yaml_config].to_s.scrub if File.exists?(opts[:yaml_config].to_s.scrub)
        vpassfile = opts[:vpassfile].to_s.scrub if File.exists?(opts[:vpassfile].to_s.scrub)

        begin
          if File.extname(yaml_config) == '.yaml'
            config_resp = YAML.load(`sudo ansible-vault view #{yaml_config} --vault-password-file #{vpassfile}`)
          else
            config_resp = `sudo ansible-vault view #{yaml_config} --vault-password-file #{vpassfile}`
          end

          return config_resp
        rescue => e
          return e.message
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

          #{self}.encrypt(
            :yaml_config => 'required - yaml config to encrypt',
            :vpassfile => 'required - path to anisble-vault pass file'
          )

          #{self}.decrypt(
            :yaml_config => 'required - yaml config to decrypt',
            :vpassfile => 'required - path to anisble-vault pass file'
          )

          #{self}.authors
        }
      end
    end
  end
end
