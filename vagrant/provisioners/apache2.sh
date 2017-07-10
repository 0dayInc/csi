#!/bin/bash
domain_name=$(hostname -d)
sudo /bin/bash --login -c "sed -i \"s/DOMAIN/${domain_name}/g\" /etc/apache2/sites-available/*.conf"
