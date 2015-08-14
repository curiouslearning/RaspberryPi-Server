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

success_message="success removing archived_files"
incomplete_message="files archived not yet deleted"
failure_message="failure removing archived_files"


function main() {
	# get last line of log
	local files_removed=$( awk '/./{line=$0} END{print line}' "$archiver_log" )

	# if tar was incompelete
	if [[ $( ls -c "$archiver_temp" | wc -l ) -gt 0 ]]; then
		# remove incomplete tars
		sudo rm $archiver_temp*
		# run archiver again
		sudo /home/pi/RaspberryPi-Server/archiver/archiver.sh
	fi


	# if removal process was incomplete
	if [[ "$files_removed" = "$failure_message" ||
	      "$files_removed" = "$incomplete_message" ]]; then
		# TODO: might want to put .db in config
		sudo rm $data_dir*.db 
		# process is now complete
		echo "$success_message" >> "$archiver_log"
	fi
	exit
}

main
