# frozen_string_literal: true

require 'tty-prompt'

module CSI
  module Plugins
    # This plugin is used to assist in masking a password when entered in via
    # STDIN to prevent would-be shoulder surfers from obtaining password
    # information.  This plugin is useful when demonstrating the functionality
    # of other SP plugins/modules.
    module AuthenticationHelper
      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.username

      public_class_method def self.username
        user = TTY::Prompt.new.ask('Username: ')
        user.to_s.strip.chomp.scrub
      rescue StandardError => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.mask_password(
      #   prompt: 'optional - string to display at prompt'
      # )

      public_class_method def self.mask_password(opts = {})
        opts[:prompt].nil? ? prompt = 'Password' : prompt = opts[:prompt].to_s.scrub.strip.chomp

        pass = TTY::Prompt.new.mask("#{prompt}: ")
        pass.to_s.strip.chomp.scrub
      rescue StandardError => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.mfa(
      #   prompt: 'optional - string to display at prompt'
      # )

      public_class_method def self.mfa(opts = {})
        opts[:prompt].nil? ? prompt = 'MFA Token' : prompt = opts[:prompt].to_s.scrub.strip.chomp

        mfa = TTY::Prompt.new.ask("#{prompt}: ")
        mfa.to_s.strip.chomp.scrub
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
          #{self}.username

          #{self}.mask_password

          #{self}.mfa(
            prompt: 'optional - string to display at prompt'
          )

          #{self}.authors
        "
      end
    end
  end
end
