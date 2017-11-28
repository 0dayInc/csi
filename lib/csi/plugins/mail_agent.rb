# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin is used for sending email from multiple mail agents such as
    # corporate mail, yahoo, hotmail/live, and mail relays (spoofing).  Supports
    # sending multiple file attachments and works pretty well.
    module MailAgent
      # Supported Method Parameters::
      # parent_mail_agent(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   address: 'smtp server ip or domain',
      #   port: 'smtp port',
      #   tls_auto: true|false,
      #   username: 'optional',
      #   password: 'optional',
      #   debug: true|false
      # )
      @@logger = CSI::Plugins::CSILogger.create

      private

      def self.parent_mail_agent(opts = {})
        from = opts[:from]
        to = opts[:to]
        cc = opts[:cc]
        bcc = opts[:bcc]
        reply_to = opts[:reply_to]
        subject = opts[:subject]
        html_body = opts[:html_body]
        txt_body = opts[:txt_body] # If HTML is NOT supported or desired
        authentication = opts[:authentication]
        attachments_hash = {}
        # opts[:attachments_hash]&.each do |attachment_name, attachment_path|
        unless attachments_hash.empty?
          opts[:attachments_hash].each do |attachment_name, attachment_path|
            attachments_hash[attachment_name] = File.binread(attachment_path)
          end
        end

        debug = opts[:debug]

        address = opts[:address]
        port = opts[:port]
        tls_auto = opts[:tls_auto]
        username = opts[:username]
        password = if !username.nil? && opts[:password].nil?
                     CSI::Plugins::AuthenticationHelper.mask_password
                   else
                     opts[:password]
                   end

        if debug == true
          @@logger.info("DEBUG ENABLED: from: #{from.inspect}, to: #{to.inspect}, cc: #{cc.inspect}, bcc: #{bcc.inspect}, reply_to: #{reply_to} subject: #{subject.inspect}, html_body: #{html_body.inspect}, txt_body: #{txt_body.inspect}, attachments: #{attachments_hash.inspect}, address: #{address.inspect}, port: #{port.inspect}, username: #{username.inspect}, password: #{password.inspect} enable_starttls_auto: #{tls_auto.inspect}, authentication: #{authentication.inspect}")
        end
        # The :body symbol below is known to be problematic until the author of pony fixes it.  better to use :html_body symbol
        CSI::Plugins::Pony.mail(
          from: from,
          to: to,
          cc: cc,
          bcc: bcc,
          reply_to: reply_to,
          subject: subject,
          html_body: html_body,
          body: txt_body,
          attachments: attachments_hash,
          via: :smtp,
          via_options: {
            address: address,
            port: port,
            enable_starttls_auto: tls_auto,
            user_name: username,
            password: password,
            authentication: authentication,
            domain: 'localhost.localdomain'
          }
        )
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::MailAgent.office365(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   username: 'required username',
      #   password: 'optional (but will be prompted if not submitted)',
      #   debug: true|false
      # )

      public

      def self.office365(opts = {})
        # Send mail from corporate mail solution
        opts[:address] = 'smtp.office365.com'
        opts[:port] = 587
        opts[:tls_auto] = true
        opts[:authentication] = :login
        parent_mail_agent(opts)
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::MailAgent.gmail(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   username: 'required',
      #   password: 'optional (but will be prompted if not submitted)'
      #   debug: true|false
      # )

      public

      def self.gmail(opts = {})
        opts[:address] = 'smtp.gmail.com'
        opts[:port] = 587
        opts[:tls_auto] = true
        opts[:authentication] = :plain
        parent_mail_agent(opts)
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::MailAgent.hotmail_n_live(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   username: 'required',
      #   password: 'optional (but will be prompted if not submitted)'
      #   debug: true|false
      # )

      public

      def self.hotmail_n_live(opts = {})
        opts[:address] = 'smtp.live.com'
        opts[:port] = 587
        opts[:tls_auto] = true
        opts[:authentication] = :plain
        parent_mail_agent(opts)
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::MailAgent.yahoo(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   username: 'required',
      #   password: 'optional (but will be prompted if not submitted)'
      #   debug: true|false
      # )

      public

      def self.yahoo(opts = {})
        opts[:address] = 'smtp.mail.yahoo.com'
        opts[:port] = 587
        opts[:tls_auto] = true
        opts[:authentication] = :plain
        parent_mail_agent(opts)
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::MailAgent.spoof(
      #   from: 'required',
      #   to: 'required',
      #   cc: 'optional',
      #   bcc: 'optional',
      #   reply_to: 'optional',
      #   subject: 'optional',
      #   html_body: 'optional',
      #   txt_body: 'optional alternative to :html_body',
      #   attachments_hash: {
      #     'attachment_name1.doc': 'attachment file path 1',
      #     'attachment_name2.xls': 'attachment file path 2'
      #   },
      #   address: 'smtp server ip or domain',
      #   port: 'smtp port',
      #   tls_auto: true|false,
      #   username: 'optional',
      #   password: 'optional',
      #   debug: true|false
      # )

      public

      def self.spoof(opts = {})
        # Spoof mail from known relay
        opts[:authentication] = :plain if opts[:authentication].nil?
        parent_mail_agent(opts)
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
          #{self}.office365(
            from: 'required',
            to: 'required',
            cc: 'optional',
            bcc: 'optional',
            reply_to: 'optional',
            subject: 'optional',
            html_body: 'optional',
            txt_body: 'optional alternative to :html_body',
            attachments_hash: {
              'attachment_name1.doc': 'attachment file path 1',
              'attachment_name2.xls': 'attachment file path 2'
            },
            username: 'required domain\\username',
            password: 'optional (but will be prompted if not submitted)',
            debug: true|false
          )

          #{self}.gmail(
            from: 'required',
            to: 'required',
            cc: 'optional',
            bcc: 'optional',
            reply_to: 'optional',
            subject: 'optional',
            html_body: 'optional',
            txt_body: 'optional alternative to :html_body',
            attachments_hash: {
              'attachment_name1.doc': 'attachment file path 1',
              'attachment_name2.xls': 'attachment file path 2'
            },
            username: 'required',
            password: 'optional (but will be prompted if not submitted)'
            debug: true|false
          )

          #{self}.hotmail_n_live(
            from: 'required',
            to: 'required',
            cc: 'optional',
            bcc: 'optional',
            reply_to: 'optional',
            subject: 'optional',
            html_body: 'optional',
            txt_body: 'optional alternative to :html_body',
            attachments_hash: {
              'attachment_name1.doc': 'attachment file path 1',
              'attachment_name2.xls': 'attachment file path 2'
            },
            username: 'required',
            password: 'optional (but will be prompted if not submitted)'
            debug: true|false
          )

          #{self}.yahoo(
            from: 'required',
            to: 'required',
            cc: 'optional',
            bcc: 'optional',
            reply_to: 'optional',
            subject: 'optional',
            html_body: 'optional',
            txt_body: 'optional alternative to :html_body',
            attachments_hash: {
              'attachment_name1.doc': 'attachment file path 1',
              'attachment_name2.xls': 'attachment file path 2'
            },
            username: 'required',
            password: 'optional (but will be prompted if not submitted)'
            debug: true|false
          )

          #{self}.spoof(
            from: 'required',
            to: 'required',
            cc: 'optional',
            bcc: 'optional',
            reply_to: 'optional',
            subject: 'optional',
            html_body: 'optional',
            txt_body: 'optional alternative to :html_body',
            attachments_hash: {
              'attachment_name1.doc': 'attachment file path 1',
              'attachment_name2.xls': 'attachment file path 2'
            },
            address: 'smtp server ip or domain',
            port: 'smtp port',
            tls_auto: true|false,
            authentication: 'optional defaults to :plain - available :login, :plain, or :cram_md5',
            username: 'optional',
            password: 'optional',
            debug: true|false
          )

          #{self}.authors
        "
      end
    end
  end
end
