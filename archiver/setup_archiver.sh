#!/bin/bash
# setup_archiver
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directory to be used by archiving script
# exits with 0 if successful and another number otherwise
#

source /home/pi/RaspberryPi-Server/config.sh

success=0

sudo mkdir "$archive_dir"
success=$(($success|$?))
# might want to send something to a log

sudo chmod 777 "$archive_dir"
success=$(($success|$?))
# might want to send something to a log

exit "$success"
