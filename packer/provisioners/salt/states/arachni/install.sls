{% set envs = {'arachni_root': '/opt/arachni', 'arachni_build_path': '/opt/arachni/arachni-1.5.1-0.5.12', 'arachni_pkg': 'arachni-1.5.1-0.5.12-linux-x86_64.tar.gz', 'arachni_url': 'https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz'} %}

{% for key, value in envs.iteritems %}
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

{% for file in salt['cmd.run']('ls /opt/arachni/arachni/bin/') %}
create_{{ file }}_symlink:
  file.symlink:
    - name: /usr/bin/local/{{ file }}
    - target: /opt/arachni/arachni/{{ file }}
    - force: True
{% endfor %}