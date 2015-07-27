#!/bin/bash
# archiver.sh
# By Jason Krone for Curious Learning
# Date: June 8, 2015
# archives tablet data
# TODO: write another script to run this script so that we
# can retry archiving of data a given number of times if 
# archiving fails
#



echo "$(date)" >> /home/pi/RaspberryPi-Server/archiver/test_a

# get variables from config
source /home/pi/RaspberryPi-Server/config.sh
extension=".db"

# purp: creates a compressed archive of all files with the given extension
# in the directory specified and then stores the created archive in the 
# given archive folder
# args: path to directory of files to archive, extension of files to be compressed E.g. (.db), 
# path to archive folder
# rets: 0 if successful; otherwise returns non-zero value 
function archive_dir() {
    # if there is at least one file in the directory with the extension
    if [[ $(cd "$1" && ls -l *$2 | wc -l) -gt 0 ]]; then
        # use seconds since epoch as archive name
        local arc_name=$(date +%s)
        # create archive
        (cd "$1" && sudo tar -czf $3$arc_name.tar.gz *$2)
        # remove archived files if tar was successful
        if [[ "$?" -eq 0 ]]; then
            sudo rm $1*$2
			echo "was able to archive files"
            return 0 
        else
			echo "was not able to archive files"
            # Error tar was unsuccessful could not create archive
            return 1
        fi
    else
        return 0
    fi 
}

archive_dir $data_dir $extension $archive_dir

exit
