#!/bin/bash
git pull && rake && rake install && rake rerdoc && gem rdoc --rdoc --ri --overwrite -V csi && echo "Invoking bundle-audit Gemfile Scanner..." && bundle-audit update && bundle-audit
