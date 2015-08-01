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
archiver_log="/home/pi/RaspberryPi-Server/archiver_log.txt"


function main() {
	# is there >= one file in the directory with the extension
	if [[ $(cd "$data_dir" && ls -l *$extension | wc -l) -gt 0 ]]; then
		archive_dir $data_dir $extension $archive_dir
		echo "$?"
		exit "$?"
	# there are no files to archive
	else
		exit 0
	fi
}


# purp: creates a compressed archive of all files with the given extension
# in the directory specified and then stores the created archive in the 
# given archive folder
# args: path to directory of files to archive, extension of files to be compressed E.g. (.db), 
# path to archive folder
# rets: 0 if successful; otherwise returns non-zero value 
function archive_dir() {
	echo "$(date)" >> "$archiver_log"
	local success=0

	# use seconds since epoch as archive name
	local arc_name=$(date +%s)
	success=$?
	log_success $success "getting seconds since epoch"

	if [[ "$success" -eq 0 ]]; then
		# create archive
		(cd "$1" && sudo tar -czf $3$arc_name.tar.gz *$2)
		success=$?
		log_success $success "archiving files"

		# remove archived files if tar was successful
		if [[ "$success" -eq 0 ]]; then
			sudo rm $1*$2
		fi
	fi
	return "$success"
}


# purp: if arg1 is 0, prints success message with subject given in arg2
# otherwise, if arg1 is non-zero, prints failure message with given subject
# args: arg1 - exit_value, arg2 - subject of message
# rets: nothing
function log_success() {
	if [[ $1 -eq 0 ]]; then
		echo "success $2" >> "$archiver_log" 
	else
		echo "failure $2" >> "$archiver_log"
	fi
}


main
