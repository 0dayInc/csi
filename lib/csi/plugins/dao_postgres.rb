require 'pg'

module CSI
  module Plugins
    # This plugin is a data access object used for interacting w/ PostgreSQL databases.
    module DAOPostgres
      # Supported Method Parameters::
      # CSI::Plugins::DAOPostgres.connect(
      #   :host => 'required host or IP', 
      #   :port => 'optional port (defaults to 5432)', 
      #   :dbname => 'required database name', 
      #   :user => 'required username', 
      #   :password => 'optional (prompts if left blank)', 
      #   :connect_timeout => 'optional (defaults to 60 seconds)', 
      #   :options => 'optional postgres options', 
      #   :tty => 'optional tty', 
      #   :sslmode => :disable|:allow|:prefer|:require
      # )
      public
      def self.connect(opts = {})
        host = opts[:host].to_s

        if opts[:port].nil? || opts[:port] == 0
          port = 5432
        else
          port = opts[:port].to_i
        end

        dbname = opts[:dbname].to_s
        user = opts[:user].to_s

        if opts[:password].nil?
          password = CSI::Plugins::AuthenticationHelper.mask_password
        else
          password = opts[:password].to_s
        end
        
        if opts[:connect_timeout].nil?
          connect_timeout = 60
        else
          connect_timeout = opts[:connect_timeout].to_i
        end        
  
        options = opts[:options]
        tty = opts[:tty]

        case opts[:sslmode]
          when :disable
            sslmode = 'disable'
          when :allow
            sslmode = 'allow'
          when :prefer
            sslmode = 'prefer'
          when :require
            sslmode = 'require'
        else
          raise "Error: Invalid :sslmode => #{opts[:sslmode]}. Valid params are :disable, :allow, :prefer, or :require"
        end
        #krbsrvname = opts[:krbsrvname] # << Not supported by pg 0.17.1
        #gsslib = opts[:gsslib] # << Not supported by pg 0.17.1
        #service = opts[:service] # << Not supported by pg 0.17.1

        begin
          pg_conn = PG::Connection.new(
            host: host,
            port: port,
            dbname: dbname,
            user: user,
            password: password,
            connect_timeout: connect_timeout,
            options: options,
            tty: tty,
            sslmode: sslmode
          )

          validate_pg_conn(pg_conn: pg_conn)
          return pg_conn
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOPostgres.sql_statement(
      #   :pg_conn => pg_conn, 
      #   :prepared_statement => 'SELECT * FROM tn_users WHERE state = $1', 
      #   :statement_params => ['Active']
      # )
      public
      def self.sql_statement(opts ={})
        pg_conn = opts[:pg_conn]
        validate_pg_conn(pg_conn: pg_conn)
        prepared_statement = opts[:prepared_statement] # Can also be leveraged for 'select * from user;'
        statement_params = opts[:statement_params] # << Array of Params
        unless statement_params.class == Array || statement_params.nil?
          raise "Error: :statement_params => #{statement_params.class}. Pass as an Array object"
        end

        begin
          if statement_params.nil?
            res = pg_conn.exec(prepared_statement)
          else
            res = pg_conn.exec(prepared_statement, statement_params)
          end
          return res
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # Method Parameters Not Implemented
      public
      def self.list_all_schemas_by_host(opts = {})

      end

      # Supported Method Parameters::
      # Method Parameters Not Implemented
      public
      def self.list_all_databases_by_schema(opts = {})

      end

      # Supported Method Parameters::
      # Method Parameters Not Implemented
      public
      def self.list_all_tables_by_database(opts = {})

      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOPostgres.list_all_columns_by_table(
      #   :pg_conn => pg_conn, 
      #   :schema => 'required schema name', 
      #   :table_name => 'required table name'
      # )
      public
      def self.list_all_columns_by_table(opts = {})
        pg_conn = opts[:pg_conn]
        validate_pg_conn(pg_conn: pg_conn)

        table_schema = opts[:table_schema].to_s
        table_name = opts[:table_name].to_s

        prep_sql = "
          SELECT * FROM information_schema.columns
          WHERE table_schema = $1
          AND table_name = $2
        "

        res = sql_statement(
          pg_conn: pg_conn, 
          prepared_statement: prep_sql, 
          statement_params: [table_schema, table_name]
        )

        return res
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOPostgres.disconnect(
      #   :pg_conn => pg_conn
      # )
      public
      def self.disconnect(opts = {})
        pg_conn = opts[:pg_conn]
        validate_pg_conn(pg_conn: pg_conn)
        begin
          pg_conn.close
        rescue => e
          return e.message
        end
      end

      # Supported Method Parameters::
      # validate_pg_conn(
      #   :pg_conn => pg_conn
      # )
      private
      def self.validate_pg_conn(opts ={})
        pg_conn = opts[:pg_conn]
        unless pg_conn.class == PG::Connection
          raise "Error: Invalid pg_conn Object #{pg_conn}"
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
          pg_conn = #{self}.connect(
            :host => 'required host or IP', 
            :port => 'optional port (defaults to 5432)', 
            :dbname => 'required database name', 
            :user => 'required username', 
            :password => 'optional (prompts if left blank)', 
            :connect_timeout => 'optional (defaults to 60 seconds)', 
            :options => 'optional postgres options', 
            :tty => 'optional tty', 
            :sslmode => :disable|:allow|:prefer|:require
          )

          res = #{self}.sql_statement(
            :pg_conn => pg_conn, 
            :prepared_statement => 'SELECT * FROM tn_users WHERE state = $1', 
            :statement_params => ['Active']
          )
     
          res = #{self}.list_all_columns_by_table(
            :pg_conn => pg_conn, 
            :schema => 'required schema name', 
            :table_name => 'required table name'
          )
     
          #{self}.disconnect(:pg_conn => pg_conn)

          #{self}.authors
        }
      end
    end
  end
end
