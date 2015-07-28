#!/bin/bash
# by Jason Krone for Curious Learning
# date: July 23, 2015
# builds weserver system
#

build_log="/home/pi/RaspberryPi-Server/build/build_log.txt"

function setup_pi_server() {

	# /home/pi/RaspberryPi-Server/webserver/setup_webserver.sh
	log_setup_success $? "webserver"

	# /home/pi/RaspberryPi-Server/archiver/setup_archiver.sh
	log_setup_success $? "archiver"

	# /home/pi/RaspberryPi-Server/file_mover/setup_file_mover.sh
	log_setup_success $? "file_mover"

	# setup cronjobs
	crontab /home/pi/RaspberryPi-Server/pi_server_crontab
	log_setup_success $? "crontab"
}

# purp: if arg1 is 0, prints success message with subject given in arg2
# otherwise, if arg1 is non-zero, prints failure message with given subject
# args: arg1 - exit_value, arg2 - subject of message
# rets: nothing
function log_setup_success() {
	if [[ $1 -eq 0 ]]; then
		echo "success setting up $2" >> "$build_log" 
	else
		echo "failure setting up $2" >> "$build_log"
	fi
}

setup_pi_server
