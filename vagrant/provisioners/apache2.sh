#!/bin/bash
domain_name=$(hostname -d)
sudo /bin/bash --login -c "sed -i \"s/DOMAIN/${domain_name}/g\" /etc/apache2/sites-available/*.conf"
sudo ln -s /etc/apache2/sites-available/jenkins_80.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/jenkins_443.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/openvas_80.conf /etc/apache2/sites-enabled/
sudo ln -s /etc/apache2/sites-available/openvas_443.conf /etc/apache2/sites-enabled/
