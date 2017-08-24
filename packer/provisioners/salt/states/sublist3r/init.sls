checkout_sublist3r:
  git.latest:
    - name: https://github.com/aboul3la/Sublist3r.git
    - target: '/opt/Sublist3r'
    - branch: master
    - force_clone: True
    - force_reset: True

create_sublist3r_symlink:
  file.symlink:
    - name: /usr/local/bin/sublist3r.py
    - target: /opt/Sublist3r/sublist3r.py
    - force: True
    - require:
      - git: checkout_sublist3r
