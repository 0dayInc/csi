{% set envs = {'arachni_root': '/opt/arachni', 'arachni_build_path': '/opt/arachni/arachni-1.5.1-0.5.12', 'arachni_pkg': 'arachni-1.5.1-0.5.12-linux-x86_64.tar.gz', 'arachni_url': 'https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz'} %}

{% for key, value in envs.iteritems() %}
set_env_{{ key }}:
  environ.setenv:
    - name: {{ key }}
    - value: {{ value }}
{% endfor %}

create_arachni_root:
  file.directory:
    - name: {{ envs.arachni_root }}
    - makedirs: True

checkout_arachni:
  git.latest:
    - name: https://github.com/Arachni/arachni.git
    - target: {{ envs.arachni_root }}
    - branch: master
    - force_clone: True

arachni_create_symlink_target_dir:
  file.directory:
    - name: /usr/bin/local
    - makedirs: True

{% for file in salt['cmd.run']('ls /opt/arachni/bin/').split('\n') %}
create_{{ file }}_symlink:
  file.symlink:
    - name: /usr/bin/local/{{ file }}
    - target: /opt/arachni/bin/{{ file }}
    - force: True
    - require:
      - git: checkout_arachni
{% endfor %}
