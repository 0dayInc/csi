{% set android_pkgs = ['android-sdk', 'adb'] %}

install_android_pkgs:
  pkg.installed:
    - pkgs: android_pkgs