#!/bin/bash --login
arachni_root='/opt/arachni'
arachni_build_path="${arachni_root}/arachni-1.5.1-0.5.12"
arachni_pkg='arachni-1.5.1-0.5.12-linux-x86_64.tar.gz'
arachni_url="https://github.com/Arachni/arachni/releases/download/v1.5.1/${arachni_pkg}"

sudo /bin/bash --login -c "mkdir ${arachni_root} && cd ${arachni_root} && wget ${arachni_url} && tar -xzvf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && rm ${arachni_pkg}"

sudo /bin/bash --login -c "ls ${arachni_build_path}/bin/* | while read arachni_bin; do ln -sf ${arachni_build_path}/bin/${arachni_bin} /usr/local/bin/; done"
