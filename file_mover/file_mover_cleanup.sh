#!/bin/bash
#### BEGIN INIT INFO
# Provides:          file_mover_cleanup.sh 
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: cleans up archived unmoved archive files
# Description: finishes any processes that haven't been completed by file_mover
### END INIT INFO

# By Jason Krone for Curious Learning
# Date: July 31, 2015

source ../config.sh
source ../counter.sh
source ../array_intersect_utils.sh


function main() {
	echo "running file_mover_cleanup on $( date )" >> "$file_mover_log"

	# error with file transfer process and usb is inserted
	if [[ $( mount | grep /mnt/usb ) != "" && 
	      $( num_files_in_dir "$file_mover_temp" ) -gt 0 ]]; then
		echo "files in temp and usb mounted" >> "$file_mover_log"
		./file_mover.sh
	fi


	# temp should also be empty for this to be the case
	# checking temp may avoid previous prolem in testing
	# see if removal of backedup files was incomplete
	if [[ $( num_files_in_dir "$backup_dir" ) -gt 0 &&
	      $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
		local backup_files=( "$backup_dir"* )
		local archive_files=( "$archive_dir"* )

		# get duplicates
		local duplicates=($( intersection archive_files[@] backup_files[@] file_eq ))

		# remove any duplicates
		sudo rm ${duplicates[@]}
	fi

	exit
}


main
