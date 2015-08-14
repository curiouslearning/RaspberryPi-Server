#!/bin/bash
# setup_archiver.sh
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directory to be used by archiving script
# and sets archiver_cleanup.sh to be run on boot
# exits with 0 if successful and another number otherwise
#

source /home/pi/RaspberryPi-Server/config.sh
arc_cleanup="/home/pi/RaspberryPi-Server/archiver/archiver_cleanup.sh"
arc_cleanup_boot="/etc/init.d/archiver_cleanup.sh"

success=0

sudo mkdir "$archive_dir"
success=$(($success|$?))
sudo chmod 777 "$archive_dir"
success=$(($success|$?))


# create temp dir for creating tars
sudo mkdir "$archiver_temp"
success=$(($success|$?))
sudo chmod 777 "$archiver_temp"
success=$(($success|$?))


# set archiver_cleanup.sh to be run on boot
sudo mv "$arc_cleanup" "$arc_cleanup_boot" 
success=$(($success|$?))
sudo chmod 777 "$arc_cleanup_boot"
success=$(($success|$?))
sudo update-rc.d archiver_cleanup.sh defaults
success=$(($success|$?))

echo "$success"
exit "$success"
