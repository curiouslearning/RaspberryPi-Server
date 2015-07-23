#!/bin/bash
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Installs php and apache2 on Pi for webserver
#

# TODO: pull this from config
tablet_dir="/mnt/s3/"
data_dir="globallit-tabletdata/"


# install apache and php
sudo apt-get install apache2 -y

# without the update system fails to install php
sudo apt-get update
sudo apt-get install php5 libapache2-mod-php5 -y


# swap index.html for our index.php (might want that path in config) 
sudo rm /var/www/index.html
sudo mv index.php /var/www/index.php
sudo chmod 777 /var/www/index.php


# create directory for indexed data
sudo mkdir "$tablet_dir"
sudo mkdir "$tablet_dir$data_dir"
sudo chmod 777 "$tablet_dir$data_dir"

exit 
