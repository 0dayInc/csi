#!/bin/bash
sudo /bin/bash --login -c 'greenbone-certdata-sync && greenbone-nvt-sync && greenbone-scapdata-sync'
