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

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
source $raspi_base_path/utils/counter.sh
source $raspi_base_path/utils/cleanup_utils.sh
source $raspi_base_path/utils/logger.sh

file_mover_log="file_mover/file_mover_log.txt"


function main() {
	log_status 0 "running file_mover_cleanup on $( date )" "$file_mover_log"

	# error with file transfer process and usb is inserted
	if [[ $( mount | grep /mnt/usb ) != "" && 
	      $( num_files_in_dir "$file_mover_temp" ) -gt 0 ]]; then
		"$raspi_base_path"/file_mover/file_mover.sh
		log_status $? "cleaning up after error in transfer to usb" "$file_mover_log"
	fi

	# see if removal of backedup files was incomplete
	if [[ $( num_files_in_dir "$backup_dir" ) -gt 0 &&
	      $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
		local backup_files=( "$backup_dir"* )
		local archive_files=( "$archive_dir"* )

		# get duplicates
		local duplicates=($( intersection archive_files[@] backup_files[@] file_eq ))

		# remove any duplicates
		sudo rm ${duplicates[@]}

		log_status $? "removing duplicates from incomplete file mover process" "$file_mover_log"
	fi

	exit
}


main
