# frozen_string_literal: true
require 'base64'

module CSI
  module Plugins
    # This plugin Base64 encodes/decodes AuthN credentials for passing to a ''Basic'' 
    # authorization HTTP header.
    module BasicAuth
      # Supported Method Parameters::
      # CSI::Plugins::BasicAuth.encode(
      #   :username => 'optional username', 
      #   :password => 'optional password'
      # )
      public
      def self.encode(opts = {})
        basic_user = opts[:username].to_s.chomp unless opts[:username].nil?
        basic_pass = opts[:password].to_s.chomp unless opts[:password].nil?
        base64_str = "#{basic_user}:#{basic_pass}"
        @base64_encoded_auth = Base64.encode64(base64_str).to_s.chomp
        return @base64_encoded_auth
      end
    
      # Supported Method Parameters::
      # CSI::Plugins::BasicAuth.decode(
      #   :base64_str => 'required base64 encoded string'
      # )
      public
      def self.decode(opts = {})
        base64_str = opts[:base64_str]
        @base64_decoded_auth = Base64.decode64(base64_str)
        return @base64_decoded_auth
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "
       
        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts "USAGE:
          #{self}.encode(
            :username => 'optional username', 
            :password => 'optional password'
          )

          #{self}.decode(:base64_str => 'base64 encoded string')
 
          #{self}.authors
        "
      end
    end
  end
end
