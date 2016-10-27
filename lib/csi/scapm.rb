# frozen_string_literal: true
module CSI
  # This file, using the autoload directive loads SP static code analysis
  # modules into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module SCAPM
    # Zero False Negative SCAPM Modules
    autoload :ApacheFileSystemUtilAPI, 'csi/scapm/apache_file_system_util_api'
    autoload :AMQPConnectAsGuest, 'csi/scapm/amqp_connect_as_guest'
    autoload :AWS, 'csi/scapm/aws'
    autoload :BannedFunctionCallsC, 'csi/scapm/banned_function_calls_c'
    autoload :Base64, 'csi/scapm/base64'
    autoload :BeefHook, 'csi/scapm/beef_hook'
    autoload :CmdExecutionJava, 'csi/scapm/cmd_execution_java'
    autoload :CmdExecutionPython, 'csi/scapm/cmd_execution_python'
    autoload :CmdExecutionRuby, 'csi/scapm/cmd_execution_ruby'
    autoload :CmdExecutionScala, 'csi/scapm/cmd_execution_scala'
    autoload :CSRF, 'csi/scapm/csrf'
    autoload :Emoticon, 'csi/scapm/emoticon'
    autoload :Eval, 'csi/scapm/eval'
    autoload :Factory, 'csi/scapm/factory'
    autoload :FilePermission, 'csi/scapm/file_permission'
    autoload :InnerHTML, 'csi/scapm/inner_html'
    autoload :Keystore, 'csi/scapm/keystore'
    autoload :Logger, 'csi/scapm/logger'
    autoload :Password, 'csi/scapm/password'
    autoload :PomVersion, 'csi/scapm/pom_version'
    autoload :Port, 'csi/scapm/port'
    autoload :Redirect, 'csi/scapm/redirect'
    autoload :ReDOS, 'csi/scapm/redos'
    autoload :SQL, 'csi/scapm/sql'
    autoload :SSL, 'csi/scapm/ssl'
    autoload :TaskTag, 'csi/scapm/task_tag'
    autoload :ThrowErrors, 'csi/scapm/throw_errors'
    autoload :Token, 'csi/scapm/token'
    autoload :Version, 'csi/scapm/version'

    # Display a List of Each Static Code Anti-Pattern Matching Module

    public

    def self.help
      constants.sort
    end
  end
end
