# frozen_string_literal: true

require 'highline/import'

module CSI
  module Plugins
    # This plugin is used to assist in masking a password when entered in via
    # STDIN to prevent would-be shoulder surfers from obtaining password
    # information.  This plugin is useful when demonstrating the functionality
    # of other SP plugins/modules.
    module AuthenticationHelper
      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.username

      public

      def self.username
        user = HighLine.new.ask('Username: ')
        user.to_s.scrub.chomp
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.mask_password

      public

      def self.mask_password
        pass = HighLine.new.ask('Password: ') { |q| q.echo = "\*" }
        pass.to_s.scrub.chomp
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::AuthenticationHelper.mfa(
      #   prompt: 'optional - string to display at prompt'
      # )

      public

      def self.mfa(opts = {})
        prompt = opts[:prompt].to_s.scrub.strip.chomp
        mfa = HighLine.new.ask("#{prompt}: ")
        mfa.to_s.scrub.chomp
      rescue => e
        raise e
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
