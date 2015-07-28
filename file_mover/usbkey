#!/bin/bash
# by Jason Krone for curious learning
# Date: July 20, 2015
# automatically mounts and unmounts usb
# 


ACTION=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

source /home/pi/RaspberryPi-Server/config.sh

function main() {
	if [[ "$ACTION" = "add" ]]; then
		move_archives_to_usb
	else
	# usb is being removed
		sudo umount "$usb_mnt_point" 
	fi
	exit $?
}

# purp: mounts usb if usb has the correct id file and then moves files to usb
# args: none
# rets: 0 if successful
function move_archives_to_usb() {
	sudo mount "$usb_mnt_point" 

	if [[ "$?" -eq 0 ]]; then
		# check that this is a file_mover usb
		if [[ $( cat /mnt/usb/usb_id ) = "file_mover_usb" ]]; then
			# move files to usb
			/home/pi/RaspberryPi-Server/file_mover/file_mover.sh 
		else
			# usb is not meant to store files
			sudo umount "$usb_mnt_point"	
		fi
		return 0
	else
		echo "problem mounting usb" >> "$file_mover_log" 
		return 1
	fi
}

main
