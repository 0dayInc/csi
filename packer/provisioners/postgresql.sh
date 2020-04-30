#!/bin/bash --login
source /etc/profile.d/globals.sh

if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

csi_provider=`echo $CSI_PROVIDER`

pdb='csi'

$screen_cmd "${apt} install -y postgresql ${assess_update_errors}"
grok_error

if [[ $csi_provider == 'docker' ]]; then
  $screen_cmd "/etc/init.d/postgresql start ${assess_update_errors}"
  grok_error
else
  $screen_cmd "sudo systemctl enable postgresql ${assess_update_errors}"
  grok_error
  $screen_cmd "sudo systemctl restart postgresql ${assess_update_errors}"
  grok_error
fi


$screen_cmd "sudo -iu postgres createdb ${pdb} ${assess_update_errors}"
grok_error

function create_table() {
  current_table="${1}"
  csi_table_def=$(cat <<EOF
    create table ${current_table} (
      id SERIAL PRIMARY KEY,
      row_result varchar(33000) NOT NULL
    );
EOF
  )
  echo csi_table_def | sudo -iu postgres psql -X -d $pdb
  grok_error
}

create_table 'scapm'
create_table 'fuzz_net_app_proto'
