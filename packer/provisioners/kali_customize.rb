#!/usr/bin/env ruby
# frozen_string_literal: true

# A list of these are available in /usr/share/applications/*.desktop
panel_root = '/usr/share/applications'

system("sudo chmod 777 #{panel_root}")

File.open("#{panel_root}/csi-prototyper.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=csi'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "cd /csi && csi"'
  f.puts 'Icon=gksu-root-terminal'
  f.puts 'StartupNotify=false'
  f.puts 'Terminal=true'
  f.puts 'Type=Application'
end

File.open("#{panel_root}/csi-drivers.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=csi drivers'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "cd /csi/bin && ls"'
  f.puts 'Icon=org.gnome.Software'
  f.puts 'StartupNotify=false'
  f.puts 'Terminal=true'
  f.puts 'Type=Application'
end

File.open("#{panel_root}/csi-chromium-jenkins.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=Jenkins'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "/usr/bin/chromium https://jenkins.$(hostname -d)"'
  f.puts 'Icon=dconf-editor'
  f.puts 'Type=Application'
  f.puts 'Categories=Network;WebBrowser;'
  f.puts 'MimeType=text/html;text/xml;application/xhtml_xml;application/x-mimearchive;x-scheme-handler/http;x-scheme-handler/https;'
  f.puts 'StartupWMClass=chromium'
  f.puts 'StartupNotify=true'
end

File.open("#{panel_root}/csi-chromium-openvas.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=OpenVAS'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "/usr/bin/chromium https://openvas.$(hostname -d)"'
  f.puts 'Terminal=false'
  f.puts 'X-MultipleArgs=false'
  f.puts 'Type=Application'
  f.puts 'Icon=kali-OpenVas.png'
  f.puts 'Categories=Network;WebBrowser;'
  f.puts 'MimeType=text/html;text/xml;application/xhtml_xml;application/x-mimearchive;x-scheme-handler/http;x-scheme-handler/https;'
  f.puts 'StartupWMClass=chromium'
  f.puts 'StartupNotify=true'
end

File.open("#{panel_root}/csi-msfconsole.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=metasploit framework'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "cd /opt/metasploit-framework-dev && sudo msfconsole"'
  f.puts 'Icon=kali-metasploit.png'
  f.puts 'StartupNotify=false'
  f.puts 'Terminal=true'
  f.puts 'Type=Application'
end

File.open("#{panel_root}/csi-setoolkit.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=social engineering toolkit'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c "sudo setoolkit"'
  f.puts 'Icon=kali-set.png'
  f.puts 'StartupNotify=false'
  f.puts 'Terminal=true'
  f.puts 'Type=Application'
  f.puts 'Categories=08-exploitation-tools;13-social-engineering-tools;'
  f.puts 'X-Kali-Package=set'
end

system("sudo chown root:root #{panel_root}/*.desktop")
system("sudo chmod 755 #{panel_root}")

panel_items = %(
[
  'gnome-control-center.desktop',
  'csi-prototyper.desktop',
  'csi-drivers.desktop',
  'terminator.desktop',
  'csi-chromium-jenkins.desktop',
  'csi-chromium-openvas.desktop',
  'chromium.desktop',
  'firefox-esr.desktop',
  'kali-burpsuite.desktop',
  'kali-zaproxy.desktop',
  'csi-msfconsole.desktop',
  'kali-searchsploit.desktop',
  'csi-setoolkit.desktop',
  'org.gnome.Nautilus.desktop'
]
)

# Create the Custom Kali Panel
system("dconf write /org/gnome/shell/favorite-apps \"#{panel_items}\"")

# Use the CSI Wallpaper
system('gsettings set org.gnome.desktop.background picture-uri file:///csi/documentation/virtualbox-gui_wallpaper.jpg')
