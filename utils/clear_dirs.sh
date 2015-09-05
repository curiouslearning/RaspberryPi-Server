#!/bin/bash
# by Jason Krone for Curious Learning
# Date: Sept 5, 2015
# clears everything needed for tests to run correctly 


raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh

function main() {
	sudo rm "$data_dir"*
	sudo rm "$archive_dir"*
	sudo rm "$archiver_temp"*
	sudo rm "$backup_dir"*
	sudo rm "$file_mover_temp"*
	sudo rm "$usb_mnt_point"*.gz
	echo "" > $raspi_base_path/space_manager/test_log.txt
	echo "" > $raspi_base_path/space_manager/deleted_files.txt
}


main
