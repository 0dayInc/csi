{% set pkgs = ['wget', 'fontconfig', 'postgresql-server-dev-all', 'libpcap-dev', 'libsndfile1', 'libsndfile-dev', 'imagemagick', 'libmagickwant-dev', 'tesseract-ocr-all'] %}

{% for pkg in pkgs %}
{{ pkg }}:
  pkg.installed: {}
{% endfor %}

tesseract_trained_data:
  file.managed:
    - name: /usr/share/tesseract-ocr/eng.traineddata
    - source: https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/eng.traineddata
    - makedirs: True
