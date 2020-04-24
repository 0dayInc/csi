#!/bin/bash --login
source /etc/profile.d/globals.sh
pdb='csi'

$screen_cmd "${apt} install -y postgresql ${assess_update_errors}"
grok_error

$screen_cmd "/etc/init.d/postgresql start ${assess_update_errors}"
grok_error

$screen_cmd "sudo -iu postgres createdb ${pdb} ${assess_update_errors}"
grok_error

# csi_scapm
csi_scapm_table_def=$(cat <<EOF
  create table scapm (
    id SERIAL PRIMARY KEY,
    timestamp timestamp with time zone NOT NULL,
    scapm_module varchar(90) NOT NULL,
    section varchar(90) NOT NULL,
    nist_800_53_uri varchar(90) NOT NULL,
    filename varchar(600) NOT NULL,
    line_no_and_contents varchar(9000) NOT NULL,
    raw_content varchar(9000) NOT NULL,
    test_case_filter varchar(3000) NOT NULL
  );
EOF
)

$screen_cmd "echo ${csi_scapm_table_def} | sudo -iu postgres psql -X -d ${pdb}"
grok_error
