#!/usr/bin/env ruby
# frozen_string_literal: true

if ENV['CSI_ROOT']
  csi_root = ENV['CSI_ROOT']
elsif Dir.exist?('/csi')
  csi_root = '/csi'
else
  csi_root = Dir.pwd
end

# A list of these are available in /usr/share/applications/*.desktop
panel_root = '/usr/share/applications'
wallpaper = "#{csi_root}/documentation/csi_wallpaper.jpg"

system("sudo chmod 777 #{panel_root}")

File.open("#{panel_root}/csi-prototyper.desktop", 'w') do |f|
  f.puts '[Desktop Entry]'
  f.puts 'Name=csi'
  f.puts 'Encoding=UTF-8'
  f.puts 'Exec=/bin/bash --login -c csi'
  f.puts 'Icon=gksu-root-terminal'
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
  f.puts 'Icon=kali-openvas.png'
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
  f.puts 'Icon=kali-metasploit-framework.png'
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
  'org.gnome.tweaks.desktop',
  'csi-prototyper.desktop',
  'csi-drivers.desktop',
  'terminator.desktop',
  'kali-recon-ng.desktop',
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

# Gnome
# Create the Custom Kali Panel
system("dconf write /org/gnome/shell/favorite-apps \"#{panel_items}\"")

# Use the CSI Wallpaper
system("gsettings set org.gnome.desktop.background picture-uri file://#{wallpaper}")
system('gsettings set org.gnome.desktop.background picture-options "centered"')

# Always Show the Panel
system('gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true')

# XFCE
# Do not show icons on Desktop
system('xfconf-query --channel xfce4-desktop --property /desktop-icons/file-icons/show-home --set false')
system('xfconf-query --channel xfce4-desktop --property /desktop-icons/file-icons/show-trash --set false')
system('xfconf-query --channel xfce4-desktop --property /desktop-icons/file-icons/show-removable --set false')
system('xfconf-query --channel xfce4-desktop --property /desktop-icons/file-icons/show-filesystem --set false')

# Create the Custom Kali Panel
system('xfconf-clipman &')
system("xfce4-panel --add launcher #{panel_root}/csi-prototyper.desktop")
system("xfce4-panel --add launcher #{panel_root}/csi-drivers.desktop")
system("xfce4-panel --add launcher #{panel_root}/terminator.desktop")
system("xfce4-panel --add launcher #{panel_root}/kali-recon-ng.desktop")
system("xfce4-panel --add launcher #{panel_root}/csi-chromium-jenkins.desktop")
system("xfce4-panel --add launcher #{panel_root}/csi-chromium-openvas.desktop")
system("xfce4-panel --add launcher #{panel_root}/chromium.desktop")
system("xfce4-panel --add launcher #{panel_root}/firefox-esr.desktop")
system("xfce4-panel --add launcher #{panel_root}/kali-burpsuite.desktop")
system("xfce4-panel --add launcher #{panel_root}/kali-zaproxy.desktop")
system("xfce4-panel --add launcher #{panel_root}/csi-msfconsole.desktop")
system("xfce4-panel --add launcher #{panel_root}/kali-searchsploit.desktop")
system("xfce4-panel --add launcher #{panel_root}/csi-setoolkit.desktop")

# Use the CSI Wallpaper for LightDm Greeter
system("sudo sed -i '/background/c\background = #{wallpaper}' /etc/lightdm/lightdm-gtk-greeter.conf")
# Use the CSI Wallpaper
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set #{wallpaper}")
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor1/image-path --set #{wallpaper}")
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/last-single-image --set #{wallpaper}")
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor1/last-single-image --set #{wallpaper}")
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVGA-1/workspace0/last-image --set #{wallpaper}")
system("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVGA-1/workspace1/last-image --set #{wallpaper}")
