# frozen_string_literal: true
require 'bunny'

module CSI
  module Plugins
    # This plugin is used to interact w/ RabbitMQ via ruby.
    module RabbitMQHole
      # Supported Method Parameters::
      # CSI::Plugins::RabbitMQHole.open(
      #   :hostname => 'required',
      #   :username => 'optional',
      #   :password => 'optional'
      # )

      public

      def self.open(opts = {})
        host = opts[:hostname].to_s
        user = opts[:username].to_s
        pass = opts[:password].to_s

        this_amqp_obj = Bunny.new("amqp://#{user}:#{pass}@#{host}")
        this_amqp_obj.start
      end

      # Supported Method Parameters::
      # CSI::Plugins::RabbitMQHole.close(
      #   :amqp_oject => amqp_conn1
      # )

      public

      def self.close(opts = {})
        this_amqp_obj = opts[:amqp_obj]
        this_amqp_obj.close_connection
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
        puts %{USAGE:
          amqp_conn1 = #{self}.open(
            :hostname => 'required',
            :username => 'optional',
            :password => 'optional'
          )

          #{self}.close(:amqp_oject => amqp_conn1)"

          #{self}.authors
        }
      end
    end
  end
end
