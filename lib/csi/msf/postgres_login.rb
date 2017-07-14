# frozen_string_literal: true

module CSI
  module MSF
    # This exploit module checks whether Postgres daemons have default passwords in use.
    module PostgresLogin
      # Supported Method Parameters::
      # CSI::MSF::PostgresLogin.exploit(
      #   msfrpcd_yaml_conf: '/path/to/yaml/conf/file',
      #   blank_passwords: 'optional try blank passwords for all users',
      #   bruteforce_speed: 'required how fast to bruteforce, from 0 to 5 (defaults to 5)',
      #   database: 'required the database to authenticate against (defaults to postgres)',
      #   db_all_creds: 'optional try each user/password couple stored in the current database (defaults to false)',
      #   db_all_pass: 'optional add all passwords in the current database to the list (defaults to false)',
      #   db_all_users: 'optional add all users in the current database to the list (defaults to false)',
      #   password: 'optional specific password to authenticate with',
      #   pass_file: 'optional ile containing passwords, one per line (defaults to /usr/local/share/csi/postgres_default_pass.txt)',
      #   proxies: 'optional use a proxy chain',
      #   return_rowset: 'optional set to true to see query result sets (defaults to true)',
      #   rhosts: 'required target address range or CIDR identifier',
      #   rport: 'required target port (defaults to 5432)',
      #   stop_on_sucess: 'required stop guessing when a credential works for a host (defaults to false)',
      #   threads: 'required number of concurrent threads (defaults to 1)',
      #   username: 'optional specific username to authenticate as (defaults to postgres)',
      #   userpass_file: 'optional file containing (space-seperated) users and passwords, one pair per line (defaults to /usr/local/share/csi/postgres_default_userpass.txt)',
      #   user_as_pass: 'optional try the username as the password for all users (defaults to false)',
      #   user_file: 'optional file containing users, one per line (defaults to /usr/local/share/csi/postgres_default_user.txt)
      # )
      # e.g. result = CSI::MSF::PostgresLogin.exploit(
      #                msfrpcd_yaml_conf: '/csi/etc/metasploit/vagrant.yaml',
      #                rhosts: '<domain_name>',
      #                rport: 5432
      #              )

      public

      def self.exploit(opts = {})
        msfrpcd_yaml_conf = opts[:msfrpcd_yaml_conf]

        msf_client = CSI::Plugins::Metasploit.connect(msfrpcd_yaml_conf: msfrpcd_yaml_conf)

        msf_module = 'auxiliary/scanner/postgres/postgres_login'

        blank_passwords = if opts[:blank_passwords].nil?
                            false
                          else
                            opts[:blank_passwords]
                          end

        bruteforce_speed = if opts[:bruteforce_speed].nil?
                             5
                           else
                             opts[:bruteforce_speed]
                           end

        database = if opts[:database].nil?
                     'postgres'
                   else
                     opts[:database]
                   end

        db_all_creds = if opts[:db_all_creds].nil?
                         false
                       else
                         opts[:db_all_creds]
                       end

        db_all_pass = if opts[:db_all_pass].nil?
                        false
                      else
                        opts[:db_all_pass]
                      end

        db_all_users = if opts[:db_all_users].nil?
                         false
                       else
                         opts[:db_all_users]
                       end

        password = opts[:password]

        if opts[:pass_file].nil?
          pass_file = '/usr/local/share/csi/postgres_default_pass.txt'
        else
          pass_file = opts[:pass_file]
        end

        proxies = opts[:proxies]

        return_rowset = if opts[:return_rowset].nil?
                          true
                        else
                          opts[:return_rowset]
                        end

        rhosts = opts[:rhosts]

        rport = if opts[:rport].nil?
                  5432
                else
                  opts[:rport]
                end

        stop_on_sucess = if opts[:stop_on_success].nil?
                           false
                         else
                           opts[:stop_on_sucess]
                         end

        threads = if opts[:threads].nil?
                    1
                  else
                    opts[:threads]
                  end

        username = if opts[:username].nil?
                     'postgres'
                   else
                     opts[:username]
                   end

        if opts[:userpass_file].nil?
          userpass_file = '/usr/local/share/csi/postgres_default_userpass.txt'
        else
          userpass_file = opts[:userpass_file]
        end

        user_as_pass = if opts[:user_as_pass].nil?
                         false
                       else
                         opts[:user_as_pass]
                       end

        if opts[:user_file].nil?
          user_file = '/usr/local/share/csi/postgres_default_user.txt'
        else
          user_file = opts[:user_file]
        end

        msf_module_opts = {
          blank_passwords: blank_passwords,
          bruteforce_speed: bruteforce_speed,
          database: database,
          db_all_creds: db_all_creds,
          db_all_pass: db_all_pass,
          db_all_users: db_all_users,
          password: password,
          pass_file: pass_file,
          proxies: proxies,
          return_rowset: return_rowset,
          rhosts: rhosts,
          rport: rport,
          stop_on_sucess: stop_on_sucess,
          threads: threads,
          username: username,
          userpass_file: userpass_file,
          user_as_pass: user_as_pass,
          user_file: user_file,
          verbose: true
        }

        result = CSI::Plugins::Metasploit.exec(
          msfrpcd_conn: msf_client,
          msf_module: msf_module,
          msf_module_opts: msf_module_opts
        )

        CSI::Plugins::Metasploit.disconnect(
          msfrpcd_conn: msf_client
        )

        result
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

      # Used primarily to map NIST 800-53 Revision 4 Security Controls
      # https://web.nvd.nist.gov/view/800-53/Rev4/impact?impactName=HIGH
      # to CSI Exploit & Static Code Analysis Modules to
      # Determine the level of Testing Coverage w/ CSI.

      public

      def self.nist_800_53_requirements
        nist_800_53_requirements = {
          sp_module: self,
          section: '1.7.7',
          nist_800_53_uri: 'https://web.nvd.nist.gov/view/800-53/Rev4/control?controlName=IA-5'
        }
        nist_800_53_requirements
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          #{self}.exploit(
            msfrpcd_yaml_conf: '/path/to/yaml/conf/file',
            blank_passwords: 'optional try blank passwords for all users',
            bruteforce_speed: 'required how fast to bruteforce, from 0 to 5 (defaults to 5)',
            database: 'required the database to authenticate against (defaults to postgres)',
            db_all_creds: 'optional try each user/password couple stored in the current database (defaults to false)',
            db_all_pass: 'optional add all passwords in the current database to the list (defaults to false)',
            db_all_users: 'optional add all users in the current database to the list (defaults to false)',
            password: 'optional specific password to authenticate with',
            pass_file: 'optional ile containing passwords, one per line (defaults to /usr/local/share/csi/postgres_default_pass.txt)',
            proxies: 'optional use a proxy chain',
            return_rowset: 'optional set to true to see query result sets (defaults to true)',
            rhosts: 'required target address range or CIDR identifier',
            rport: 'required target port (defaults to 5432)',
            stop_on_sucess: 'required stop guessing when a credential works for a host (defaults to false)',
            threads: 'required number of concurrent threads (defaults to 1)',
            username: 'optional specific username to authenticate as (defaults to postgres)',
            userpass_file: 'optional file containing (space-seperated) users and passwords, one pair per line (defaults to /usr/local/share/csi/postgres_default_userpass.txt)',
            user_as_pass: 'optional try the username as the password for all users (defaults to false)',
            user_file: 'optional file containing users, one per line (defaults to /usr/local/share/csi/postgres_default_user.txt)
          )

          #{self}.authors
        "
      end
    end
  end
end
