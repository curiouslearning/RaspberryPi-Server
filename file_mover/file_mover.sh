# !/bin/bash
# file_mover.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# Moves archived tablet data to USB stick, then adds moved archives to backups
#

source /home/pi/RaspberryPi-Server/logger.sh
source /home/pi/RaspberryPi-Server/counter.sh
source /home/pi/RaspberryPi-Server/config.sh


function main() {
	echo "running file_mover.sh on $(date)" >> "$file_mover_log"
	local success=0

	# are there files to move ?
	if [[ $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
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
	log_status $success "getting list of archives" "$file_mover_log"

	if [[ $success -eq 0 ]]; then 
		sudo cp $archive_dir* "$file_mover_temp"
		success=$?
		log_status $success "copying archives to temp" "$file_mover_log"
	fi 	

	if [[ $success -eq 0 ]]; then 
		# copy files from temp to usb
		sudo cp $file_mover_temp* $usb_mnt_point	
		success=$?
		log_status $success "copying archives to usb" "$file_mover_log"
	fi
	
	if [[ $success -eq 0 ]]; then 
		# move files from temp to backups
		sudo mv "$file_mover_temp"* "$backup_dir"
		success=$?
		log_status $success "backing up archives" "$file_mover_log"
	fi

	if [[ $success -eq 0 ]]; then 
		# remove backedup files from archive
		sudo rm ${archived_files[@]}
		log_status $success "removing backups from archive" "$file_mover_log"
	fi

	return "$success"
}


main
