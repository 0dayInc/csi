{% set firefox_plugin_path = '/csi/third_party/geckodriver-v0.13.0-linux64.tar.gz' %}

extract_geckodriver:
  archive.extracted:
    - name: /usr/local/bin
    - source: {{ firefox_plugin_path }}