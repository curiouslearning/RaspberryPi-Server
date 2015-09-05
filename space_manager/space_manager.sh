#!/bin/bash
# space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Checks that there is at least 1GB of availible space on Pi 
# and if there is not, delete files to make room
#

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
source $raspi_base_path/logger.sh
source $raspi_base_path/counter.sh


space_manager_log="/space_manager/space_manager_log.txt"
in_test_mode="true" # TODO: get rid of this.. just see if param present


function main() {
	log_status 0 "running space manager on $(date)" "$space_manager_log"
	local space_needed=0
	local space_created=1
	local success_making_space=0 # 0 indicates success
	local initial_space="$( python3 available_space.py )"
	local space_avail=$initial_space

	# TODO check using param1
	if [[ "$in_test_mode" == "true" ]]; then
		# $1 is minimum space required in test mode
		space_needed=$1
	else
		space_needed=$min_required_space
	fi

	# delete files until there is sufficent free space on Pi
	while [[ "$space_avail" -lt $space_needed && 
		  "$space_created" -ne 0 ]]; do
		space_created=$( make_space )
		success_making_space=$?
		log_status $success_making_space "making space" "$space_manager_log"
		space_avail=$(( $space_avail + $space_created ))
	done

	echo "$initial_space" # for testing purposes
	exit "$success_making_space"
}


# purp: deletes the oldest file/archive from backups, archive, data
# folders in that order of preference. (E.g if there are no backups
# it will attempt to delete the oldest archive) and outputs the size
# of the file deleted in kb
# args: none
function make_space() {
	local space_made=0

	# TODO: in future this order could be pulled from config 
	# and this could be put in a for loop 
	if [[ $( num_files_in_dir "$backup_dir" ) -gt 0 ]]; then
		# delete the oldest backup
		space_made=$( delete_oldest_file "$backup_dir" )
	elif [[ $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
		# delete the oldest archive
		space_made=$( delete_oldest_file "$archive_dir" )
	elif [[ $( num_files_in_dir "$data_dir" ) -gt 0 ]]; then
		# delete the oldest .db file 
		space_made=$( delete_oldest_file "$data_dir" )
	fi
		
	echo "$space_made"
}


# purp: deletes the file/archive with the oldest last modified date and
# logs info on the file deleted in space_manager_log and outputs 
# the size of file deleted in kb
# args: $1 - path to directory containing files
function delete_oldest_file() {
	local file_size=0
	local success=0

	# get the oldest file
	local file=$( ls -tr "$1" | head -n 1 )
	file_size=$( du "$1$file" | cut -f1 )
	sudo rm "$1$file"

	success=$?
	if [[ $success -ne 0 ]]; then
		# deletion failed so no space was made
		file_size=0
	fi

	if [[ "$in_test_mode" == "false" ]]; then
		log_status "$success" "deleting file: $1$file to make space" "$space_manager_log"
	else
		echo "$1$file" >> $raspi/file_mover/deleted_files.txt
	fi

	echo "$file_size"
}

main $1
