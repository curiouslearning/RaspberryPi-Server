#!/bin/bash
# space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Checks that there is at least 1GB of availible space on Pi 
# and if there is not, delete files to make room
#

source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/logger.sh
source /home/pi/RaspberryPi-Server/counter.sh

in_test_mode="true" 


function main() {
	echo "running space manager on $(date)" >> "$space_manager_log" 

	# $1 is minimum space required in test mode
	local test_space_needed=$1

 	# see if there is sufficent space i.e. at least 1GB free
	local has_space=$( has_free_space $test_space_needed )
	local success_making_space=0 # 0 indicates success

	# delete files until there is sufficent free space on Pi
	while [[ "$has_space" == "false" && "$success_making_space" -eq 0 ]]; do
		make_space
		# capture exit status of make_space
		success_making_space=$?
		log_status $success_making_space "making space" "$space_manager_log" 
		# see if we still need more space
		local has_space=$( has_free_space $1 )
	done
	exit "$success_making_space"
}


# purp: outputs true if the pi has enough space and false otherwise
# args: $1 - free space needed for pi in test mode
function has_free_space() {
	local_has_space="true"
	# TODO: use relative path
	local free_space=$(python3 available_space.py)

	if [[ "$test_mode" == "true" ]]; then
		if [[ "$free_space" -lt "$1" ]]; then
			has_space="false"
		fi
	elif [[ "$free_space" -lt "$min_required_space" ]]; then
		has_space="false"
	fi

	echo "$has_space"
}



# purp: deletes the oldest file/archive from backups, archive, data
# folders in that order of preference. (E.g if there are no backups
# it will attempt to delete the oldest archive)
# args: none
# rets: 0 if a file was deleted, 1 if there were no files to delete
function make_space() {
	local exit_status=0

	# TODO: in future this order could be pulled from config 
	# and this could be put in a for loop 
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


# purp: deletes the file/archive with the oldest last modified date and
# logs info on the file deleted in space_manager_log
# args: $1 - path to directory containing files
# rets: 0 if successful, non-zero int otherwise
function delete_oldest_file() {
	local success=0

	# get the oldest file
	local file=$( ls -tr "$1" | head -n 1 )
	sudo rm "$1$file"

	success=$?
	if [[ "$in_test_mode" == "false" ]]; then
		log_status "$success" "deleting file: $1$file to make space" "$space_manager_log"
	else
		echo "$1$file" >> deleted_files.txt
	fi

	return $success
}


main
