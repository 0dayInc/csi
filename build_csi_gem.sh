#!/bin/bash
git pull && rake && rake install && rake rerdoc && gem rdoc --rdoc --ri --overwrite -V csi
