/etc/rc.local:
  file.managed:
    - contents:
      - #!/bin/sh -e
      - ifconfig lo:0 127.0.0.2 netmask 255.0.0.0 up
      - ifconfig lo:1 127.0.0.3 netmask 255.0.0.0 up
      - ifconfig lo:2 127.0.0.4 netmask 255.0.0.0 up
      - sudo -H -u vagrant /usr/local/bin/toggle_tor.sh
      - exit 0
    - mode: 755