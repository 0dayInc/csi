require "csi/version"

# Thank you for choosing the Continuous Security Integrtion Framework!
# Your Source for Source Code Analysis, Vulnerability Scanning, Exploitation, 
# & General Security Testing in a Continuous Integration Environment
module CSI
  STDOUT.sync = true # < Ensure that all print statements output progress in realtime
  STDOUT.flush       # < Ensure that all print statements output progress in realtime
  autoload :ExploitModules, 'csi/exploit_modules'
  autoload :Plugins, 'csi/plugins'
  autoload :Reports, 'csi/reports'
  autoload :SCAPM, 'csi/scapm'
  autoload :WebApp, 'csi/web_app'
  autoload :WWW, 'csi/www'
  
  # Display Usage for the CSI Framework ~
  public
  def self.help
    return self.constants.sort
  end

  public
  def self.toggle_pager
    if _pry_.config.pager
      _pry_.config.pager = false
    else
      _pry_.config.pager = true
    end
  end
end
