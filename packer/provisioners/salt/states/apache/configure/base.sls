include:
  - apache.install

set_env_domain_name:
  environ.setenv:
    - name: domain_name
    - value: {{ salt['cmd.run']('hostname -d') }}

{% set mods = ['proxy', 'proxy_http', 'rewrite', 'ssl', 'headers'] %}

{% for mod in mods  %}
enable_mod_{{ mod }}:
  cmd.run:
    - name: |
        a2enmod {{ mod }}
    - require:
      - pkg: apache2
#  apache_module.enabled:
#    - name: {{ mod }}
#  module.run:
#    - name: apache.a2enmod
#    - mod: {{ mod }}
{% endfor %}

/etc/apache2/apache2.conf:
  file.append:
    - text:
      - ServerSignature Off
      - ServerTokens Prod
    - require:
      - pkg: apache2

apache2_service_running:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2
      - file: /etc/apache2/apache2.conf
