#!/bin/bash --login
port=$1

ruby -run -e httpd . -p $port
