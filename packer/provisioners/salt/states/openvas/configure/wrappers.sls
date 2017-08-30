checkout_openvas_wrappers:
  git.latest:
    - name: https://github.com/ninp0/openvas_wrappers.git
    - target: /opt
    - branch: master
    - force_clone: True

{% set files = ['continuous_openvas_scan_task.sh', 'continuous_openvas_scan_task_cert_authn.sh'] %}

{% for file in files %}
create_{{ file }}_symlink:
  file.symlink:
    - name: /usr/local/bin/{{ file }}
    - target: /opt/openvas_wrappers/{{ file }}
    - force: True
    - require:
      - git: checkout_openvas_wrappers
{% endfor %}