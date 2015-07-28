#!/bin/bash
# space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Checks that there is at least 1GB of availible space on Pi 
# and if there is not, delete files to make room
#

echo "$(date)" >> /home/pi/RaspberryPi-Server/space_manager/test_sm

source /home/pi/RaspberryPi-Server/config.sh
space_manager_log="/home/pi/RaspberryPi-Server/space_manager/space_manager_log.txt"


function main() {
    # see if there is sufficent space i.e. at least 1GB free
	local space_needed=$(python3 ~/RaspberryPi-Server/space_manager/available_space.py)
	local success_making_space=0 # 0 indicates success

	# delete files until there is sufficent free space on Pi
	while [[ "$space_needed" -eq 1 && "$success_making_space" -eq 0 ]]; do
		make_space
		# capture exit status of make_space
		success_making_space=$?
		# see if we still need more space
		space_needed=$(python3 ~/RaspberryPi-Server/space_manager/available_space.py)
	done
	exit "$success_making_space"
}


# purp: deletes the oldest file/archive from backups, archive, data
# folders in that order of preference. (E.g if there are no backups
# it will attempt to delete the oldest archive)
# args: none
# rets: 0 if a file was deleted, 1 if there were no files to delete
function make_space() {
	local exit_status=0
	if [[ $( num_files_in_dir "$backup_dir" ) -gt 0 ]]; then
		# delete the oldest backup
		delete_oldest_file "$backup_dir"
		exit_status=$(($exit_status|$?))
	elif [[ $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
		# delete the oldest archive
		delete_oldest_file "$archive_dir"
		exit_status=$(($exit_status|$?))
	elif [[ $( num_files_in_dir "$data_dir" ) -gt 0 ]]; then
		# delete the oldest .db file 
		delete_oldest_file "$data_dir"
		exit_status=$(($exit_status|$?))
	else 
		echo "nothing to delete"
		# there was some type of failure
		exit_status=1	
	fi
	return "$exit_status"
}


# purp: ouputs the number of files in the given directory
# args: path to the directory
# rets: nothing 
function num_files_in_dir() {
	local num_files=$( ls -c "$1" | wc -l )
	echo "$num_files"
}


# purp: deletes the file/archive with the oldest last modified and
# logs info on the file deleted in space_manager_log
# date in the given directory
# args: path to directory containing files
# rets: 0 if successful 
function delete_oldest_file() {
	local success=0

	# get the oldest file
	local file=$( ls -tr "$1" | head -n 1 )
	echo "deleting file $1$file"
	sudo rm "$1$file"

	success=$?
	if [[ success -eq 0 ]]; then
		echo "deleted file: $1$file to make space" >> "$space_manager_log"
	else
		echo "problem deleting file: $1$file" >> "$space_manager_log"
	fi

	return $success
}

main
