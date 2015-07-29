#!/bin/bash
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Installs php and apache2 on Pi for webserver
#

source /home/pi/RaspberryPi-Server/config.sh
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
sudo mv /home/pi/RaspberryPi-Server/webserver/index.php /var/www/index.php
success=$(($success|$?))
sudo chmod 777 /var/www/index.php
success=$(($success|$?))


# create directory for indexed data
sudo mkdir "$tablet_dir"
success=$(($success|$?))
sudo mkdir "$data_dir"
success=$(($success|$?))
sudo chmod 777 "$data_dir"
success=$(($success|$?))

exit "$success"
