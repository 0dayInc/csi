checkout_nmap_all_live_hosts:
  git.latest:
    - name: https://github.com/ninp0/nmap_all_live_hosts.git
    - target: /opt
    - branch: master
    - force_clone: True

create_nmap_all_live_hosts_symlink:
  file.symlink:
    - name: /usr/local/bin/nmap_all_live_hosts.sh
    - target: /opt/nmap_all_live_hosts/nmap_all_live_hosts.sh
    - force: True
    - require:
      - git: checkout_nmap_all_live_hosts