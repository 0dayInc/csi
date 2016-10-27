# frozen_string_literal: true
require 'slack-ruby-client'

module CSI
  module Plugins
    # This plugin is used for interacting w/ Slack over the Web API.
    module SlackClient
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::Plugins::SlackClient.login(
      #   :api_token => 'required slack api token'
      # )

      public

      def self.login(opts = {})
        api_token = opts[:api_token]

        if opts[:api_token].nil?
          api_token = CSI::Plugins::AuthenticationHelper.mask_password
        else
          api_token = opts[:api_token].to_s.scrub
        end

        begin
          @@logger.info('Logging into Slack...')
          slack_obj = Slack::Web::Client.new
          slack_obj.token = api_token
          slack_obj.auth_test

          return slack_obj
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::SlackClient.post_message(
      #   :slack_obj => 'required slack_obj returned from login method',
      #   :channel => 'required #channel to post message',
      #   :message => 'required message to post'
      # )

      public

      def self.post_message(opts = {})
        slack_obj = opts[:slack_obj]
        channel = opts[:channel].to_s.scrub
        message = opts[:message].to_s.scrub

        begin
          slack_obj.chat_postMessage(
            channel: channel,
            text: message,
            as_user: true
          )

          return slack_obj
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::SlackClient.logout(
      #   :slack_obj => 'required slack_obj returned from login method'
      # )

      public

      def self.logout(opts = {})
        slack_obj = opts[:slack_obj]
        @@logger.info('Logging out...')
        slack_obj.token = nil
        slack_obj = nil
        @@logger.info('Complete.')
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
          slack_obj = #{self}.login(
            :api_token => 'optional slack api token (will prompt if blank)'
          )

          #{self}.post_message(
            :slack_obj => 'required slack_obj returned from login method',
            :channel => 'required #channel to post message',
            :message => 'required message to post'
          )

          #{self}.logout(
            :slack_obj => 'required slack_obj returned from login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
