#!/bin/bash
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Installs php and apache2 on Pi for webserver
#

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
success=0


# install apache and php
sudo apt-get install apache2 -y
success=$(($success|$?))

# without the update system fails to install php
sudo apt-get update
success=$(($success|$?))
sudo apt-get install php5 libapache2-mod-php5 -y
success=$(($success|$?))


# swap index.html for our index.php (might want that path in config) 
sudo rm /var/www/index.html
success=$(($success|$?))
sudo mv $raspi_base_path/webserver/index.php /var/www/index.php
success=$(($success|$?))
sudo chmod 755 /var/www/index.php   # check that this is necessary
success=$(($success|$?))


sudo apt-get -y install mysql-server
success=$(($success|$?))


# create directory for indexed data
sudo mkdir "$tablet_dir"
success=$(($success|$?))
sudo mkdir "$data_dir"
success=$(($success|$?))
sudo chmod 777 "$data_dir"
success=$(($success|$?))

exit "$success"
