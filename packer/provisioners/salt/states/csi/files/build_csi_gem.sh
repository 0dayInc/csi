#!/bin/bash
rm pkg/*.gem
git pull
rake
rake install
rake rerdoc
gem rdoc --rdoc --ri --overwrite -V csi
bundle update
bundle-audit update
echo "Invoking bundle-audit Gemfile Scanner..."
bundle-audit
