#!/bin/bash
# setup_archiver
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directory to be used by archiving script
# and sets archiver_cleanup.sh to be run on boot
# exits with 0 if successful and another number otherwise
#

source /home/pi/RaspberryPi-Server/config.sh
cleanup="/home/pi/RaspberryPi-Server/archiver/archiver_cleanup.sh"
cleanup_boot="/etc/init.d/archiver_cleanup.sh"
temp="/mnt/s3/archive_temp/ # TODO create this 

success=0

sudo mkdir "$archive_dir"
success=$(($success|$?))
# might want to send something to a log

sudo chmod 777 "$archive_dir"
success=$(($success|$?))
# might want to send something to a log

# set archiver_cleanup.sh to be run on boot
sudo mv "$cleanup" "$cleanup_boot" 
success=$(($success|$?))
sudo chmod 777 "$cleanup_boot"
success=$(($success|$?))
sudo update-rc.d archiver_cleanup.sh defaults
success=$(($success|$?))

echo "$success"
exit "$success"
