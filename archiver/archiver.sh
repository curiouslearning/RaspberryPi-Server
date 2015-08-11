#!/bin/bash
# archiver.sh
# By Jason Krone for Curious Learning
# Date: June 8, 2015
# archives tablet data
#


echo "$(date)" >> /home/pi/RaspberryPi-Server/archiver/test_a

# get variables from config
source /home/pi/RaspberryPi-Server/config.sh
# import logger
source /home/pi/RaspberryPi-Server/logger.sh
# TODO: import temp
temp="/mnt/s3/archive_temp/"

extension=".db"

function main() {
	# is there >= one file in the directory with the extension
	if [[ $(cd "$data_dir" && ls -c *$extension | wc -l) -gt 0 ]]; then
		archive_dir $data_dir $extension $archive_dir
		echo "$?"
		exit "$?"
	# there are no files to archive
	else
		exit 0
	fi
}


# purp: creates a compressed archive of all files with the given extension
# in the directory specified and then stores the created archive in the 
# given archive folder
# args: path to directory of files to archive, extension of files to be compressed E.g. (.db), 
# path to archive folder
# rets: 0 if successful; otherwise returns non-zero value 
function archive_dir() {
	echo "$(date)" >> "$archiver_log"
	local success=0

	# use seconds since epoch as archive name
	local arc_name=$(date +%s)
	success=$?
	log_status $success "getting seconds since epoch" "$archiver_log"

	if [[ "$success" -eq 0 ]]; then
		# create archive in temp folder
		(cd "$1" && sudo tar -czf $temp$arc_name.tar.gz *$2)
		success=$?
		log_status $success "archiving files" "$archiver_log"

		if [[ "$success" -eq 0 ]]; then
			# move archived files out of temp
			sudo mv $temp$arc_name.tar.gz $3$arc_name.tar.gz
			success=$?
		
			if [[ "$success" -eq 0 ]]; then
				echo "files archived not yet deleted" >> "$archiver_log"
				sudo rm $1*$2
				log_status $? "removing archived_files" "$archiver_log"
			fi
		fi
	fi
	return "$success"
}


main
