#!/bin/bash --login
printf "Updating SSLyze Dependencies..."
sudo apt-get install -y python python-pip
echo "complete."

printf "Updating SSLyze..."
sslyze_root="/opt/sslyze-dev"
sudo /bin/bash --login -c "rm -rf ${sslyze_root} && cd /opt && git clone https://github.com/nabla-c0d3/sslyze.git sslyze-dev && cd ${sslyze_root} && pip install -r requirements.txt --target ./lib"
echo "complete."
