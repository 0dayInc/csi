#!/bin/bash --login
function wait_for_openvassd {
  sleep 3
  while true; do
    ps -ef | grep openvassd | grep "openvassd: Waiting for incoming connections" | grep -v grep
    if [ $? -eq 0 ]; then
      break
    else 
      ps -ef | grep openvassd | grep -v grep
    fi
    sleep 3
  done
}

printf "Updating OpenVas Platform Vulnerability Scanner..."
openvas_root="/opt/openvas"
admin_tmp_file="/tmp/openvas_admin.txt"

# Update Dependencies
sudo apt-get install -y subversion autoconf bison devscripts quilt libpcre3-dev libpth-dev libwrap0-dev libgmp-dev libgmp3-dev libassuan-dev dpatch pkg-config cmake flex doxygen xmltoman sqlfairy libgnutls-dev libgcrypt20 zlibc uuid-dev libfreeradius-client2 libsnmp-dev libglib2.0-dev libssh-dev libhiredis-dev libgpgme11-dev libksba-dev libldap2-dev clang gnupg xsltproc texlive-latex-base texlive-latex-recommended texlive-latex-extra gnutls-bin python-setuptools python-paramiko redis-server libgcrypt20-dev libpcap-dev libsqlite3-dev libxml2-dev libmicrohttpd-dev libxslt-dev tcl alien nsis wamerican perl-base libpopt-dev g++-mingw-w64-i686 samba python-polib smbclient nikto wapiti heimdal-dev heimdal-multidev libgss-dev

# TODO: Stop smbd daemon and disable automatic startup following reboot

sudo /bin/bash --login -c "cd /opt && svn --non-interactive --trust-server-cert checkout https://scm.wald.intevation.org/svn/openvas/trunk openvas && svn --non-interactive --trust-server-cert checkout https://scm.wald.intevation.org/svn/openvas-nvts"
sudo /bin/bash --login -c "cd ${opernvas_root} && svn --non-interactive --trust-server-cert up && cd /opt/openvas-nvts && svn --non-interactive --trust-server-cert up"

# Update OpenVas SMB
printf "Updating OpenVas SMB..."
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-smb/build && cd ${openvas_root}/openvas-smb/build && sudo cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Update OpenVas Libraries First...
printf "Updating OpenVas Libraries..."
sudo /bin/bash --login -c "cd ${openvas_root}/openvas-libraries && mkdir -p ${openvas_root}/openvas-libraries/build && cd ${openvas_root}/openvas-libraries/build && cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Update OpenVas Scanner
printf "Updating OpenVas Scanner..."
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-scanner/build && cd ${openvas_root}/openvas-scanner/build && cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Update OpenVas Manager
printf "Updating OpenVas Manager..."
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-manager/build && cd ${openvas_root}/openvas-manager/build && cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Update Greenbone Security Assistant
printf "Updating Greenbone Security Assistant..."
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/gsa/build && cd ${openvas_root}/gsa/build && sudo cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Update OpenVas Cli
printf "Updating OpenVas CLI..."
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-cli/build && cd ${openvas_root}/openvas-cli/build && sudo cmake -DCMAKE_C_COMPILER=/usr/share/clang/scan-build-3.8/libexec/ccc-analyzer .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"
echo "complete."

# Reload Libraries, Automatically set up default infrastructure for OpenVAS, Sync NVTs, & Start openvasmd/openvassd 
sudo /bin/bash --login -c "killall -15 openvassd; killall -15 openvasmd; killall -15 gsad; ldconfig; openvas-nvt-sync"
sleep 3
sudo openvasmd --listen=127.0.0.1
sleep 3
sudo openvassd --listen=127.0.0.1
wait_for_openvassd

# Get SCAP/Cert Feeds, Initialize the openvasmd DB w/ latest NVTs, retrieve auto-generated password and display at end of deployment
sudo /bin/bash --login -c "openvasmd --rebuild --progress && greenbone-scapdata-sync && greenbone-certdata-sync && gsad --listen=127.0.0.1 --port=9392 --http-only"

printf "Checking OpenVas Setup..."
sudo /bin/bash --login -c "cd ${openvas_root} && ./tools/openvas-check-setup --v9 --server"
echo "complete."

echo "OpenVas Update Complete."

printf "Restarting OpenVAS..."
sudo systemctl stop openvas.service
sleep 9
sudo systemctl start openvas.service
echo "complete."

