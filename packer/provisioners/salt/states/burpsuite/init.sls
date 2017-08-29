{% set burpsuite_pkgs = ['openjdk-8-jdk', 'maven'] %}

burpsuite_root:
  file.directory:
    - name: /opt/burpsuite

burpsuite_third_party_root:
  file.directory:
    - name: /csi/third_party/burpbuddy
    - makedirs: True

burpbuddy_build_root:
  file.directory:
    - name: /opt/burpsuite/burpbuddy/burp
    - makedirs: True

burpsuite_maven_build:
  cmd.run:
    - name: |
        cp -a /csi/third_party/burpbuddy /opt/burpsuite
        mvn package
        /opt/burpsuite/burpbuddy/burp/target/burpbuddy-2.3.1.jar /opt/burpsuite
        cp /usr/bin/burpsuite /opt/burpsuite/burpsuite-kali-native.jar
    - cwd: /opt/burpsuite/burpbuddy/burp    
    - require:
      - file: burpsuite_root
      - file: burpsuite_third_party_root