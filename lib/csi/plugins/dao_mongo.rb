# frozen_string_literal: true
require 'mongo'

module CSI
  module Plugins
    # This plugin needs additional development, however, its intent is to be
    # used as a data access object for interacting w/ MongoDB
    module DAOMongo
      # Supported Method Parameters::
      # CSI::Plugins::DAOMongo.connect(
      #   :host => 'optional host or IP defaults to 127.0.0.1',
      #   :port => 'optional port defaults to 27017',
      #   :database => 'optional database name'
      # )

      public

      def self.connect(opts = {})
        # Set host
        host = if opts[:host].nil?
                 '127.0.0.1' # Defaults to localhost
               else
                 opts[:host].to_s
               end

        # Set port
        port = if opts[:port].nil?
                 27_017 # Defaults to TCP port 27017
               else
                 opts[:port].to_i
               end

        database = opts[:database].to_s.scrub

        if opts[:database].nil?
          mongo_conn = Mongo::Client.new(["#{host}:#{port}"])
        else
          mongo_conn = Mongo::Client.new(["#{host}:#{port}"], database: database)
        end

        validate_mongo_conn(mongo_conn: mongo_conn)
        mongo_conn
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOMongo.disconnect(
      #   :mongo_conn => mongo_conn
      # )

      public

      def self.disconnect(opts = {})
        mongo_conn = opts[:mongo_conn]
        validate_mongo_conn(mongo_conn: mongo_conn)
        begin
          mongo_conn.close
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # validate_mongo_conn(
      #   :mongo_conn => mongo_conn
      # )

      private

      def self.validate_mongo_conn(opts = {})
        mongo_conn = opts[:mongo_conn]
        unless mongo_conn.class == Mongo::Client
          raise "Error: Invalid mongo_conn Object #{mongo_conn}"
        end
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
          mongo_conn = #{self}.connect(
            :host => 'optional host or IP defaults to 127.0.0.1',
            :port => 'optional port defaults to 27017',
            :database => 'optional database name'
          )

          #{self}.disconnect(:mongo_conn => mongo_conn)

          #{self}.authors
        "
      end
    end
  end
end
