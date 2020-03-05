#!/bin/bash --login
source /etc/profile.d/globals.sh

# Preferred way over to install geckodriver :)
$screen_cmd "${apt} install -y eyewitness ${assess_update_errors}"
grok_error
