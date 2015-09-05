#!/bin/bash
# cron_manager.sh
# by Jason Krone for Curious Learning
# Date: August 14, 2015
# Runs cronjobs for pi
# 

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source "$raspi_base_path"/logger.sh

space_manager="$raspi_base_path/space_manager/space_manager.sh"
archiver="$raspi_base_path/archiver/archiver.sh"


# TODO: set this up and pull hardcodedd 5
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
