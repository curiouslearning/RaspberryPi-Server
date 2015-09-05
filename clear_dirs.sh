#!/bin/bash

source /home/pi/RaspberryPi-Server/config.sh

function main() {
	sudo rm "$data_dir"*
	sudo rm "$archive_dir"*
	sudo rm "$archiver_temp"*
	sudo rm "$backup_dir"*
	sudo rm "$file_mover_temp"*
	sudo rm "$usb_mnt_point"*.gz
	echo "" > space_manager/test_log.txt
	echo "" > space_manager/deleted_files.txt
}


main
