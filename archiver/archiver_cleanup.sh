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



source ../config.sh
source ../counter.sh
source ../array_intersect_utils.sh


function main() {
	echo "running archiver_cleanup on $(date)" >> "$archiver_log"

	# failure to remove files
	if [[ $( num_files_in_dir "$archive_dir" ) -gt 0 && 
	      $( num_files_in_dir "$data_dir" ) -gt 0 ]]; then
		echo "up in here"
		# get most recent archive 
		local newest_tar=$( ls -t "$archive_dir" | head -1 )	

		# get array of files in most recent tar
		local tar_files=$( tar -tf "$archive_dir"$newest_tar )

		# get array of files in data dir
		local data_files=( "$data_dir"* )

		# get intersection 
		local duplicates=($( intersection data_files[@] tar_files[@] file_eq ))
		echo "duplicates: ${duplicates[@]}"

		# delete intersection 
		sudo rm ${duplicates[@]} 
	fi

	# if tar was incompelete
	if [[ $( num_files_in_dir "$archiver_temp" ) -gt 0 ]]; then
		# remove incomplete tars
		sudo rm $archiver_temp*
		# run archiver again
		sudo ./archiver.sh
	fi
	
	exit
}


main
