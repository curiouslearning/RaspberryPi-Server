# !/bin/bash
# file_mover.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# Moves archived tablet data to USB stick, then adds moved archives to backups
#

# TODO: put in config
usb_mount_point="/mnt/usb/"
# TODO: put in config
archive_dir="/mnt/s3/tabletdata_archive/"
# TODO: put in config
backup_dir="/mnt/s3/tabletdata_backups/"


function main() {
	echo "$(date)" >> /home/pi/RaspberryPi-Server/file_mover/log

	# are there files to move 
	if [[ $( ls -c "$archive_dir" | wc -l ) -gt 0 ]]; then
		echo "there are files to move" > /home/pi/RaspberryPi-Server/file_mover/log

		# copy archives to usb
		sudo cp $archive_dir* /mnt/usb/

		# check success 
		if [[ $? -eq 0 ]]; then
			echo "cp sucessful" >> /home/pi/RaspberryPi-Server/file_mover/log

			# move files to backups
			sudo mv $archive_dir* "$backup_dir" 

			echo "moved archives to backupdir" >> /home/pi/RaspberryPi-Server/file_mover/log
		else
			# copy failed
			exit 1
		fi
	else
		echo "no files to move" >> /home/pi/RaspberryPi-Server/file_mover/log
	fi
	exit 0
}

main
