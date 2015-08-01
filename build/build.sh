#!/bin/bash
# by Jason Krone for Curious Learning
# date: July 23, 2015
# builds weserver system
#

# import logger
source /home/pi/RaspberryPi-Server/logger.sh
build_log="/home/pi/RaspberryPi-Server/build/build_log.txt"

function main() {

	/home/pi/RaspberryPi-Server/webserver/setup_webserver.sh
	log_status $? "setting up webserver" "$build_log"

	/home/pi/RaspberryPi-Server/archiver/setup_archiver.sh
	log_status $? "setting up archiver" "$build_log"

	/home/pi/RaspberryPi-Server/file_mover/setup_file_mover.sh
	log_status $? "setting up file_mover" "$build_log"

	# setup cronjobs
	crontab /home/pi/RaspberryPi-Server/pi_server_crontab
	log_status $? "setting up crontab" "$build_log"
}

main
