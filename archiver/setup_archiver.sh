#!/bin/bash
# setup_archiver
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directory to be used by archiving script
#

source /home/pi/RaspberryPi-Server/config.sh

sudo mkdir "$archive_dir"
sudo chmod 777 "$archive_dir"

exit
