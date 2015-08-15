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


echo "on boot $(date)" >> /home/pi/RaspberryPi-Server/archiver/test_a

source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/counter.sh
source /home/pi/RaspberryPi-Server/array_intersect_utils.sh


function main() {
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
		local duplicates=$( intersection data_files[@] tar_files[@] file_eq )
		echo "duplicates: ${duplicates[@]}"

		# delete intersection 
		sudo rm ${duplicates[@]} 
	fi

	# if tar was incompelete
	if [[ $( ls -c "$archiver_temp" | wc -l ) -gt 0 ]]; then
		# remove incomplete tars
		sudo rm $archiver_temp*
		# run archiver again
		sudo /home/pi/RaspberryPi-Server/archiver/archiver.sh
	fi
	
	exit
}


main
