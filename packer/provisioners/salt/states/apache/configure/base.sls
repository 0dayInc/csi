include:
  - apache.install

set_env_domain_name:
  environ.setenv:
    - name: domain_name
    - value: salt['cmd.run']('hostname -d')

{% set mods = ['proxy', 'proxy_http', 'rewrite', 'ssl', 'headers'] %}

{% for mod in mods %}
enable_mod_proxy:
  module.run:
    - name: apache.a2enmod
    - mod: {{ mod }}
    - require:
      - pkg: apache2
{% endfor %}

/etc/apache2/apache2.conf:
  file.append:
    - text:
      - ServerSignature Off
      - ServerTokens Prod
    - require:
      - pkg: apache2