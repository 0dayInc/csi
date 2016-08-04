module CSI
  # This file, using the autoload directive loads SP plugins
  # into memory only when they're needed. For more information, see:
  # http://www.rubyinside.com/ruby-techniques-revealed-autoload-1652.html
  module WWW
    autoload :Bing, 'csi/www/bing'
    autoload :Checkip, 'csi/www/checkip.rb'
    autoload :Duckduckgo, 'csi/www/duckduckgo'
    autoload :Google, 'csi/www/google'
    autoload :Hackerone, 'csi/www/hackerone'
    autoload :Pastebin, 'csi/www/pastebin'
    autoload :Synack, 'csi/www/synack'
    autoload :Torch, 'csi/www/torch'
    autoload :Youtube, 'csi/www/youtube'

    # Display a List of Every CSI WWW module
    public
    def self.help
      return self.constants.sort
    end
  end
end
