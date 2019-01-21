# frozen_string_literal: true

require 'msfrpc-client'
require 'yaml'

module CSI
  module Plugins
    # Plugin used to integrate Metasploit into CSI leveraging a listening MSFRPCD daemon.
    module Metasploit
      # Supported Method Parameters::
      # msfrpcd_conn = CSI::Plugins::Metasploit.connect(
      #   yaml_conf: 'optional -  path to userland yaml (defaults to /csi/etc/metasploit/vagrant.yaml)'
      # )

      public_class_method def self.connect(opts = {})
        if opts[:yaml_conf].to_s.strip.chomp.scrub && File.exist?(opts[:yaml_conf].to_s.strip.chomp.scrub)
          yaml_conf = YAML.load_file(opts[:yaml_conf].to_s.strip.chomp.scrub)
        else
          yaml_conf = '/csi/etc/metasploit/vagrant.yaml'
        end

        msfrpcd_host = yaml_conf['msfrpcd_host'].to_s
        port = yaml_conf['port'].to_i
        username = yaml_conf['username'].to_s
        password = yaml_conf['password'].to_s

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
      # console_obj = CSI::Plugins::Metasploit.console_exec(
      #   msfrpcd_conn: 'required - msfrpcd_conn object returned from #connect method',
      #   cmd: 'required msfconsole command'
      # )
      def self.console_exec(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        cmd = opts[:cmd].to_s.strip.chomp.scrub

        # Create the Console and write the console_cmd to it
        console = {}
        console[:msfrpcd_conn] = msfrpcd_conn
        console[:session] = msfrpcd_conn.call('console.create')
        console[:last_cmd] = cmd
        console_id = console_obj[:session]['id']
        msfrpcd_conn.call('console.read', console_id)
        msfrpcd_conn.call('console.write', console_id, "#{cmd}\n")

        loop do
          sleep(1)
          console[:last_cmd_result] = msfrpcd_conn.call('console.read', (console['id']).to_s)

          if console[:last_cmd_result]['busy'] == true
            print 'Busy, trying again \n'
            next
          end
          break
        end

        msfrpcd_conn.call('console.destroy', (console['id']).to_s)

        console_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # console_obj = CSI::Plugins::Metasploit.console_terminate(
      #   console_obj: 'required - console_obj returned from #console_exec method to terminate'
      # )
      def self.console_terminate(opts = {})
        console_obj = opts[:console_obj]
        msfrpcd_conn = console_obj[:msfrpcd_conn]
        console_id = console_obj[:session]['id']
        msfrpcd_conn.call('console.destroy', console_id)
        console_obj = nil
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # msfrpcd_conn = CSI::Plugins::Metasploit.disconnect(
      #   msfrpcd_conn: 'required - msfrpcd_conn object returned from #connect method'
      # )

      public_class_method def self.disconnect(opts = {})
        msfrpcd_conn = opts[:msfrpcd_conn]
        msfrpcd_conn.call('auth.logout', msfrpcd_conn.token)
        msfrpcd_conn = nil
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          msfrpcd_conn = #{self}.connect(
            yaml_conf: 'optional -  path to userland yaml (defaults to /csi/etc/metasploit/vagrant.yaml)'
          )

          console_obj = #{self}.console_exec(
            msfrpcd_conn: 'required - msfrpcd_conn object returned from #connect method',
            cmd: 'required msfconsole command'
          )

          console_obj = CSI::Plugins::Metasploit.console_terminate(
            console_obj: 'required - console_obj returned from #console_exec method to terminate'
          )

          msfrpcd_conn = #{self}.disconnect(
            msfrpcd_conn: 'required - msfrpcd_conn object returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
