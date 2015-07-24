#!/bin/bash
# setup_archiver
# By Jason Krone for Curious Learning
# Date: June 15, 2015
# Creates the directory to be used by archiving script
#

# TODO: pull this from config
archive_dir="/mnt/s3/tabletdata_archive/"

sudo mkdir "$archive_dir"
sudo chmod 777 "$archive_dir"

exit
