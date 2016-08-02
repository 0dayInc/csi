#!/bin/bash
printf "Installing SIPp ***********************************************************************"
sipp_root="/opt/sipp-git"
sudo -i /bin/bash --login -c "apt-get install -y libsctp-dev && git clone https://github.com/sipp/sipp ${sipp_root} && cd ${sipp_root} && ./build.sh --full && cp ${sipp_root}/sipp /usr/local/bin"
