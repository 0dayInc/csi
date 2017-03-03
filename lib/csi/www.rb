# frozen_string_literal: true
module CSI
  # This file, using the autoload directive loads SP plugins
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module WWW
    autoload :AppCobaltIO, 'csi/www/app_cobalt_io'
    autoload :Bing, 'csi/www/bing'
    autoload :BugCrowd, 'csi/www/bug_crowd'
    autoload :Checkip, 'csi/www/checkip.rb'
    autoload :Duckduckgo, 'csi/www/duckduckgo'
    autoload :Facebook, 'csi/www/facebook'
    autoload :Google, 'csi/www/google'
    autoload :HackerOne, 'csi/www/hacker_one'
    autoload :Linkedin, 'csi/www/linkedin'
    autoload :Pastebin, 'csi/www/pastebin'
    autoload :Pandora, 'csi/www/pandora'
    autoload :Paypal, 'csi/www/paypal'
    autoload :Synack, 'csi/www/synack'
    autoload :Torch, 'csi/www/torch'
    autoload :Twitter, 'csi/www/twitter'
    autoload :Youtube, 'csi/www/youtube'

    # Display a List of Every CSI WWW module

    public

    def self.help
      constants.sort
    end
  end
end
