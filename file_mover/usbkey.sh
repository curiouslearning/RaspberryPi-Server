#!/bin/bash
# by Jason Krone for curious learning
# Date: July 20, 2015
# automatically mounts and unmounts usb
# 


ACTION=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

source /home/pi/RaspberryPi-Server/config.sh
tablet_update_script="/mnt/usb/globallit_tablet_updates.sh"

function main() {
	local success=0

	if [[ "$ACTION" = "add" ]]; then
		mount_file_mover_usb
		if [[ "$?" -eq 0 ]]; then
			# move archives to usb 
			/home/pi/RaspberryPi-Server/file_mover/file_mover.sh 

			# run tablet updates if it exist on usb
			[ -f "$tablet_update_script" ] && "$tablet_update_script"
		else
			# usb not mounted
			success=1	
		fi
	else
	# usb is being removed
		sudo umount "$usb_mnt_point" 
		success=$?
	fi
	exit "$success"
}


# purp: mounts the node symlinked to the usb mnt point if 
# that node contains the correct usb_id file, otherwise unmounts node
# args: none
# rets: 0 if the node is mounted and 1 otherwise
function mount_file_mover_usb() {
	local success=0
	sudo mount "$usb_mnt_point" 
	


	if [[ "$?" -eq 0 ]]; then
		# check that this is a file_mover usb
		if [[ $( cat /mnt/usb/usb_id ) != "file_mover_usb" ]]; then
			# usb is not meant to store files
			sudo umount "$usb_mnt_point"
			success=1
		fi
	else
		success=1	
	fi

	return "$success"
}	

main
