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


function move_files() {
	local success=0

	# cp files for usb to temp 
	sudo cp $archive_dir* "$file_mover_temp"
	
	if [[ $? -eq 0 ]]; then
		# copy files from file_mover_temp to the usb
		sudo mv $file_mover_temp* "$usb_mnt_point" 
		success=$?
		log_status $success "copying files to usb" "$file_mover_log"

		if [[ $success -eq 0 ]]; then
			# move files to backups
			echo "copied files not yet moved to backupdir" >> "$file_mover_log"
			sudo mv $archive_dir* "$backup_dir" # it could fail to do this but will catch it next time
			success=$?
			log_status $success "moving files to backup dir" "$file_mover_log"
		fi
	fi

	return $success
}

main
