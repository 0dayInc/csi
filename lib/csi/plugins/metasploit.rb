# encoding: utf-8
# frozen_string_literal: true

require 'msfrpc-client'
require 'yaml'

module CSI
  module Plugins
    # Plugin used to integrate Metasploit into CSI leveraging a listening MSFRPCD daemon.
    module Metasploit
      # Choose to use a YAML config or Pass Parameters directly to method (:msfrpcd_yaml_conf overrides passed parameters)
      # Supported Method Parameters::
      # msfrpcd_conn1 = CSI::Plugins::Metasploit.connect(
      #   msfrpcd_yaml_conf: 'optional path to YAML conf file (overrides parameters outlined below)',
      #   msfrpcd_host: 'optional Metasploit msfrpcd ip address',
      #   port: 55553,
      #   username: 'optional username for msfrpcd',
      #   password: 'optional password for msfrpcd'
      # )

      public

      def self.connect(opts = {})
        msfrpcd_yaml_conf = YAML.load_file(opts[:msfrpcd_yaml_conf].to_s) if File.exist?(opts[:msfrpcd_yaml_conf])

        if msfrpcd_yaml_conf
          print 'MSFRPCD YAML Conf Detected...'
          msfrpcd_host = msfrpcd_yaml_conf['msfrpcd_host'].to_s
          port = msfrpcd_yaml_conf['port'].to_i
          username = msfrpcd_yaml_conf['username'].to_s
          password = msfrpcd_yaml_conf['password'].to_s
        else
          msfrpcd_host = opts[:msfrpcd_host].to_s

          port = if opts[:port].nil?
                   55_553
                 else
                   opts[:port].to_i
                 end

          username = opts[:username].to_s
          password = opts[:password].to_s
        end

        # TODO: Tune Token Timeout to a Higher Value to Ensure Other
        # Module Methods Can be Used w/o Needing to Refresh Token
        msfrpcd_conn = Msf::RPC::Client.new
        msfrpcd_conn.info[:host] = msfrpcd_host
        msfrpcd_conn.info[:port] = port
        msfrpcd_conn.login(username, password)

        return msfrpcd_conn
      rescue => e
        raise "#{e}\nIs the msfrpcd daemon running on #{msfrpcd_host}?"
      end

      # Supported Method Parameters::
      # results = CSI::Plugins::Metasploit.exec(
      #   msfrpcd_conn: msfrpcd_conn1,
      #   msf_module: "required msf module name",
      #   msf_module_opts: msf_module_opts
      # )l
      def self.exec(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        msf_module = opts[:msf_module].to_s
        msf_module_opts = opts[:msf_module_opts]

        console_cmd = "use #{msf_module} \n"
        msf_module_opts.each { |option, value| console_cmd << " set #{option} #{value}\n" }
        console_cmd << "run\n"

        print "Executing #{console_cmd}" # DEBUG Print

        # Create the Console and write the console_cmd to it
        console = msfrpcd_conn.call('console.create')
        msfrpcd_conn.call('console.read', (console['id']).to_s)
        msfrpcd_conn.call('console.write', (console['id']).to_s, console_cmd)
        results = {}

        loop do
          sleep(1)
          results = msfrpcd_conn.call('console.read', (console['id']).to_s)

          if results['busy'] == true
            print 'Busy, trying again \n'
            next
          end
          break
        end

        # print "Results #{results}"
        msfrpcd_conn.call('console.destroy', (console['id']).to_s)

        results
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # auxiliary = CSI::Plugins::Metasploit.show_auxiliary(
      #   msfrpc_conn: msfrpcd_conn1
      # )

      public

      def self.show_auxiliary(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        auxiliary = msfrpcd_conn.call('module.auxiliary')

        auxiliary
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # compat_payloads = CSI::Plugins::Metasploit.show_compatible_payloads(
      #   msfrpcd_conn: msfrpcd_conn1,
      #   msf_module: "required msf module name"
      # )

      public

      def self.show_compatible_payloads(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        msf_module = opts[:msf_module].to_s
        compat_payloads = msfrpcd_conn.call('module.compatible_payloads', msf_module)

        compat_payloads
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # encoders = CSI::Plugins::Metasploit.show_encoders(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_encoders(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        encoders = msfrpcd_conn.call('module.encoders')

        encoders
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # exploits = CSI::Plugins::Metasploit.show_exploits(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_exploits(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        exploits = msfrpcd_conn.call('module.exploits')

        exploits
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # nops = CSI::Plugins::Metasploit.show_nops(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_nops(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        nops = msfrpcd_conn.call('module.nops')

        nops
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # msf_module_options = CSI::Plugins::Metasploit.show_options(
      #   msfrpcd_conn: msfrpc_conn1,
      #   msf_module_type: "required msf module type (:exploit, :auxiliary, :post, :payload, :encoder, :nop)",
      #   msf_module: "required msf module name"
      # )

      public

      def self.show_options(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        msf_module_type = opts[:msf_module_type].to_s
        msf_module = opts[:msf_module].to_s
        options = msfrpcd_conn.call('module.options', msf_module_type, msf_module)

        options
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # payloads = CSI::Plugins::Metasploit.show_payloads(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_payloads(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        payloads = msfrpcd_conn.call('module.payloads')

        payloads
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # post = CSI::Plugins::Metasploit.show_post(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_post(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        post = msfrpcd_conn.call('module.post')

        post
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # version = CSI::Plugins::Metasploit.show_version(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.show_version(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        post = msfrpcd_conn.call('core.version')

        post
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::Metasploit.disconnect(
      #   msfrpcd_conn: msfrpcd_conn1
      # )

      public

      def self.disconnect(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        msfrpcd_conn.call('auth.logout', msfrpcd_conn.token)
        msfrpcd_conn = nil # TODO: Find a way to terminate RPC socket connection to msfrpcd daemon
      rescue => e
        raise e.message
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
          msfrpcd_conn1 = #{self}.connect(
            msfrpcd_yaml_conf: 'optional path to YAML conf file (overrides parameters outlined below)',
            msfrpcd_host: 'required Metasploit msfrpcd ip address',
            port: 55553,
            username: 'required username for msfrpcd',
            password: 'required password for msfrpcd'
          )

          results = #{self}.exec(
            msfrpcd_conn: msfrpcd_conn1,
            msf_module: msf_module,
            msf_module_opts: msf_module_opts
          )

          auxiliary = #{self}.show_auxiliary(
            msfrpcd_conn: msfrpcd_conn1
          )

          encoders = #{self}.show_encoders(
            msfrpcd_conn: msfrpcd_conn1
          )

          exploits = #{self}.show_exploits(
            msfrpcd_conn: msfrpcd_conn1
          )

          nops = #{self}.show_nops(
            msfrpcd_conn: msfrpcd_conn1
          )

          options = #{self}.show_options(
            msfrpcd_conn: msfrpcd_conn1
          )

          payloads = #{self}.show_payloads(
            msfrpcd_conn: msfrpcd_conn1
          )

          post = #{self}.show_post(
            msfrpcd_conn: msfrpcd_conn1
          )

          #{self}.disconnect(
            msfrpcd_conn: msfrpcd_conn1
          )

          #{self}.authors
        "
      end
    end
  end
end
