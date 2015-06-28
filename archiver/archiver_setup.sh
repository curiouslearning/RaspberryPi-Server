#!/bin/bash
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directories to be used by archiving script
# and sets up cron job to create archives every hour
#

# TODO: pull this from config
ARCHIVE_DIR="/mnt/s3/tabletdata_archive/"

# TODO: set up cron job

sudo mkdir "$ARCHIVE_DIR"

exit
