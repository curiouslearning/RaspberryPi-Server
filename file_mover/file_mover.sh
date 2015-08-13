

# !/bin/bash
# file_mover.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# Moves archived tablet data to USB stick, then adds moved archives to backups
#

source /home/pi/RaspberryPi-Server/logger.sh
source /home/pi/RaspberryPi-Server/config.sh


function main() {
	echo "$(date)" >> "$file_mover_log"
	local success=0

	# are there files to move ?
	if [[ $( ls -c "$archive_dir" | wc -l ) -gt 0 ]]; then
		move_files
		success=$?
	fi

	exit $success 
}


# purp: moves archives to usb mount directory and then puts transfered archives
# into the backup directory
# args: none
function move_files() {
	local success=0
	# array of files to be moved
	archived_files=( "$archive_dir"* )
	success=$?

	if [[ $success -eq 0 ]]; then 
		sudo cp $archive_dir* "$file_mover_temp"
		success=$?
	fi 	

	if [[ $success -eq 0 ]]; then 
		# copy files from temp to usb
		sudo cp $file_mover_temp* $usb_mnt_point	
		success=$?
	fi
	
	if [[ $success -eq 0 ]]; then 
		# move files from temp to backups
		sudo mv "$file_mover_temp"* "$backup_dir"
		success=$?
	fi

	# if it crashes during this process there will be files in both
	# the backup dir and the archive that are the same -> duplicates
	# so cleanup should check for this case and delete any duplicates
	if [[ $success -eq 1 ]]; then 
		# remove backedup files from archive
		for file in "${archived_files[@]}"; do
			sudo rm "$file"
		done
	fi

	return $?
}


main
