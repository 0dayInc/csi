#!/bin/bash --login
source /etc/profile.d/globals.sh

$screen_cmd "${apt} install -y android-sdk"
grok_error

$screen_cmd "${apt} install -y adb"
grok_error

$screen_cmd "${apt} install -y apktool"
grok_error

$screen_cmd "${apt} install -y fastboot"
grok_error

# Bypass Certificate Pinning in Android Applications
$screen_cmd "pip3 install objection"
grok_error
