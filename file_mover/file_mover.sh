# !/bin/bash
# file_mover.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# Moves archived tablet data to USB stick, then adds moved archives to backups
#

source /home/pi/RaspberryPi-Server/config.sh

function main() {
	echo "$(date)" >> "$file_mover_log"
	success=0

	# are there files to move ?
	if [[ $( ls -c "$archive_dir" | wc -l ) -gt 0 ]]; then
		# copy archives to usb
		sudo cp $archive_dir* "$usb_mnt_point" 
		success=$?
		log_success $success "copying files to usb"

		# check success copying
		if [[ $success -eq 0 ]]; then
			# move files to backups
			sudo mv $archive_dir* "$backup_dir" 
			success=$?
			log_success $success "moving files to backup dir"
		fi
	fi
	exit $success 
}


# purp: if arg1 is 0, prints success message with subject given in arg2
# otherwise, if arg1 is non-zero, prints failure message with given subject
# args: arg1 - exit_value, arg2 - subject of message
# rets: nothing
function log_success() {
	if [[ $1 -eq 0 ]]; then
		echo "success $2" >> "$file_mover_log" 
	else
		echo "failure $2" >> "$file_mover_log"
	fi
}

main
