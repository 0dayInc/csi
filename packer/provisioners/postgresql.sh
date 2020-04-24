#!/bin/bash --login
source /etc/profile.d/globals.sh
pdb='csi'

$screen_cmd "${apt} install -y postgresql ${assess_update_errors}"
grok_error

$screen_cmd "/etc/init.d/postgresql start ${assess_update_errors}"
grok_error

$screen_cmd "sudo -iu postgres createdb ${pdb} ${assess_update_errors}"
grok_error

function create_table() {
  current_table="${1}"
  csi_table_def=$(cat <<EOF
    create table ${current_table} (
      id SERIAL PRIMARY KEY,
      row_result varchar(33000) NOT NULL,
    );
EOF
  )
  $screen_cmd "echo ${csi_table_def} | sudo -iu postgres psql -X -d ${pdb}"
  grok_error
}

create_table 'scapm'
create_table 'fuzz_net_app_proto'
