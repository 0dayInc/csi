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

printf "Installing OpenVas Platform Vulnerability Scanner *************************************"
openvas_root="/opt/openvas"
admin_tmp_file="/tmp/openvas_admin.txt"
build_clang="/usr/share/clang/scan-build-3.8/" # TODO: Make this dynamic (no version)
scan_build_path="/usr/local/libexec/ccc-analyzer"

# Install Dependencies
sudo apt-get install -y subversion autoconf bison devscripts quilt libpcre3-dev libpth-dev libwrap0-dev libgmp-dev libgmp3-dev libassuan-dev dpatch pkg-config cmake flex doxygen xmltoman sqlfairy libgnutls-dev libgcrypt20 zlibc uuid-dev libfreeradius-client2 libsnmp-dev libglib2.0-dev libssh-dev libhiredis-dev libgpgme11-dev libksba-dev libldap2-dev clang gnupg xsltproc texlive-latex-base texlive-latex-recommended texlive-latex-extra gnutls-bin python-setuptools python-paramiko redis-server libgcrypt20-dev libpcap-dev libsqlite3-dev libxml2-dev libmicrohttpd-dev libxslt-dev tcl alien nsis wamerican perl-base libpopt-dev g++-mingw-w64-i686 samba python-polib smbclient nikto wapiti heimdal-dev heimdal-multidev libgss-dev

# TODO: Stop smbd daemon and disable automatic startup following reboot

# Install ccc-analyzer
sudo /bin/bash --login -c "cd ${build_clang} && mkdir build && cd build && cmake .. && make && make install"


# Fix redis-server for some openvas default  settings
sudo /bin/bash --login -c "cp /etc/redis/redis.conf /etc/redis/redis.orig && echo \"unixsocket /var/run/redis/redis.sock\" >> /etc/redis/redis.conf && echo \"unixsocketperm 755\" >> /etc/redis/redis.conf && ln -s /var/run/redis/redis.sock /tmp/redis.sock && service redis-server restart"

sudo /bin/bash --login -c "cd /opt && svn --non-interactive --trust-server-cert checkout https://scm.wald.intevation.org/svn/openvas/trunk openvas && svn --non-interactive --trust-server-cert checkout https://scm.wald.intevation.org/svn/openvas-nvts"

# Install OpenVas SMB
printf "Installing OpenVas SMB ****************************************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-smb/build && cd ${openvas_root}/openvas-smb/build && sudo cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Install OpenVas Libraries First...
printf "Installing OpenVas Libraries **********************************************************"
sudo /bin/bash --login -c "cd ${openvas_root}/openvas-libraries && mkdir -p ${openvas_root}/openvas-libraries/build && cd ${openvas_root}/openvas-libraries/build && cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Install OpenVas Scanner
printf "Installing OpenVas Scanner ************************************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-scanner/build && cd ${openvas_root}/openvas-scanner/build && cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Install OpenVas Manager
printf "Installing OpenVas Manager ************************************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-manager/build && cd ${openvas_root}/openvas-manager/build && cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Install Greenbone Security Assistant
printf "Installing Greenbone Security Assistant ***********************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/gsa/build && cd ${openvas_root}/gsa/build && sudo cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Install OpenVas Cli
printf "Installing OpenVas CLI ****************************************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && mkdir -p ${openvas_root}/openvas-cli/build && cd ${openvas_root}/openvas-cli/build && sudo cmake -DCMAKE_C_COMPILER=${scan_build_path} .. && make && make doc && make doc-full && make install && make rebuild_cache && scan-build make"

# Reload Libraries, Automatically set up default infrastructure for OpenVAS, Sync NVTs, & Start openvasmd/openvassd 
sudo /bin/bash --login -c "ldconfig && openvas-manage-certs -av && openvas-nvt-sync && openvasmd --listen=127.0.0.1 && openvassd --listen=127.0.0.1"
wait_for_openvassd

# Get SCAP/Cert Feeds, Initialize the openvasmd DB w/ latest NVTs, retrieve auto-generated password and display at end of deployment
sudo /bin/bash --login -c "openvasmd --rebuild --progress && greenbone-scapdata-sync && greenbone-certdata-sync && openvasmd --create-user=admin --role=Admin > ${admin_tmp_file} && chown root:root ${admin_tmp_file} && chmod 400 ${admin_tmp_file} && gsad --listen=127.0.0.1 --port=9392 --http-only"

printf "Checking OpenVas Setup ****************************************************************"
sudo /bin/bash --login -c "cd ${openvas_root} && ./tools/openvas-check-setup --v9 --server"

printf "OpenVas FIRST LOGIN *******************************************************************"
sudo /bin/bash --login -c "cat $admin_tmp_file && rm $admin_tmp_file"

printf "Restarting OpenVAS ********************************************************************"
sudo /bin/bash --login -c "cp /csi/etc/systemd/openvas.service /etc/systemd/system/ && systemctl enable openvas.service && systemctl start openvas.service"
