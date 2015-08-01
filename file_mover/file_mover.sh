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
		# copy archives to usb
		sudo cp $archive_dir* "$usb_mnt_point" 
		success=$?
		log_status $success "copying files to usb" "$file_mover_log"

		# check success copying
		if [[ $success -eq 0 ]]; then
			# move files to backups
			sudo mv $archive_dir* "$backup_dir" 
			success=$?
			log_status $success "moving files to backup dir" "$file_mover_log"
		fi
	fi
	exit $success 
}

main
