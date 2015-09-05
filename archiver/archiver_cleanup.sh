#!/bin/bash
#### BEGIN INIT INFO
# Provides:          archiver_cleanup.sh 
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: cleans up archived .db files
# Description: checks that archiver deleted the files it last archived 
### END INIT INFO

# By Jason Krone for Curious Learning
# Date: July 31, 2015

# TODO: put some more logging in here

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source "$raspi_base_path"/config.sh
source "$raspi_base_path"/utils/counter.sh
source "$raspi_base_path"/utils/logger.sh
source "$raspi_base_path"/utils/cleanup_utils.sh

archiver_log="archiver/archiver_log.txt"


function main() {
	log_status 0 "running archiver_cleanup on $(date)" "$archiver_log"

	# failure to remove files
	if [[ $( num_files_in_dir "$archive_dir" ) -gt 0 && 
	      $( num_files_in_dir "$data_dir" ) -gt 0 ]]; then
		# get most recent archive 
		local newest_tar=$( ls -t "$archive_dir" | head -1 )	

		# get array of files in most recent tar
		local tar_files=$( tar -tf "$archive_dir"$newest_tar )

		# get array of files in data dir
		local data_files=( "$data_dir"* )

		# get intersection 
		local duplicates=($( intersection data_files[@] tar_files[@] file_eq ))

		# delete intersection 
		sudo rm ${duplicates[@]} 
		log_status $? "removing duplicates from data dir" "$archiver_log"
	fi

	# if tar was incompelete
	if [[ $( num_files_in_dir "$archiver_temp" ) -gt 0 ]]; then
		# remove incomplete tars
		sudo rm $archiver_temp*
		# run archiver again
		sudo "$raspi_base_path"/archiver/archiver.sh
		log_status $? "finishing incomplete archiver process" "$archiver_log"
	fi
	
	exit
}


main
