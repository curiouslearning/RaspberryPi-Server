#!/bin/bash
# archiver_cleanup.sh
# by Jason Krone for Curious Learning
# checks that the archiver deleted the files it last archived 
#

echo "$(date)" >> /home/pi/RaspberryPi-Server/archiver/test_a

source /home/pi/RaspberryPi-Server/config.sh

success_message="success removing archived_files"
incomplete_message="files archived not yet deleted"
failure_message="failure removing archived_files"

function main() {
	# get last line of log
	local files_removed=$( awk '/./{line=$0} END{print line}' "$archiver_log" )

	# if archiving process incomplete
	if [[ "$files_removed" = "$failure_message" ||
	      "$files_removed" = "$incomplete_message" ]]; then

		echo "finishing archiver"
		# TODO: might want to put .db in config
		sudo rm $data_dir*.db 
		# process is now complete
		echo "$success_message" >> "$archiver_log"
	fi
	exit
}

main
