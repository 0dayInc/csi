#!/bin/bash
sudo userdel -r -f ec2-user 2> /dev/null
echo 'Cleanup default ec2-user - complete.'
