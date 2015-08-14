#!/bin/bash
# cron_manager.sh
# by Jason Krone for Curious Learning
# Date: August 14, 2015
# Runs cronjobs for pi
# 

source /home/pi/RaspberryPi-Server/logger.sh

space_manager="/home/pi/RaspberryPi-Server/space_manager/space_manager.sh"
archiver="/home/pi/RaspberryPi-Server/archiver/archiver.sh"


function main() {
	run "$space_manager" 5
	log_status $? "running space_manager from cron manager" "$space_manager_log"
	run "$archiver" 5	
	log_status $? "running archiver from cron manager" "$archiver_log"
}

function run() {
	failures=0
	success=1
	while [[ $failures -lt "$2" && "$success" -eq 1 ]]; do
		"$1"
		success=$?
		filures=$( expr $failures + 1)
	done
	return $?
}

main
