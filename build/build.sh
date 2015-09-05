#!/bin/bash
# by Jason Krone for Curious Learning
# date: July 23, 2015
# builds weserver system
#

# import logger
source ../utils/logger.sh
build_log_path="build/build_log.txt"

# you must be in build dir when you run build script
function main() {
	# so it doesn't matter where we clone the server 
	local raspi_base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
	sudo mkdir /usr/RaspberryPi-Server/
	sudo chmod 777 /usr/RaspberryPi-Server/
	sudo echo "$raspi_base_path" > /usr/RaspberryPi-Server/base_path.txt
	log_status $? "getting base path" "$build_log_path"

	../webserver/setup_webserver.sh
	log_status $? "setting up webserver" "$build_log_path"

	../archiver/setup_archiver.sh
	log_status $? "setting up archiver" "$build_log_path"

	../file_mover/setup_file_mover.sh
	log_status $? "setting up file_mover" "$build_log_path"

	# setup cronjobs TODO: modify paths for cron jobs
	local tab="0 * * * * $raspi_base_path/cron_manager.sh"
	echo "$tab" > ../pi_server_crontab
	crontab ../pi_server_crontab
	log_status $? "setting up crontab" "$build_log_path"

	sudo reboot
}

main
