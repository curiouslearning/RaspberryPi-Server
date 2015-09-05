#!/bin/bash
# cron_manager.sh
# by Jason Krone for Curious Learning
# Date: August 14, 2015
# Runs cronjobs for pi
# 

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source "$raspi_base_path"/utils/logger.sh
source "$raspi_base_path"/config.sh

space_manager="$raspi_base_path/space_manager/space_manager.sh"
archiver="$raspi_base_path/archiver/archiver.sh"
space_manager_log="space_manager/space_manager_log.txt"
archiver_log="archiver/archiver_log.txt"


function main() {
	run "$space_manager" $max_failures
	log_status $? "running space_manager from cron manager $( date )" "$space_manager_log"
	run "$archiver" $max_failures	
	log_status $? "running archiver from cron manager $( date )" "$archiver_log"
}


# purp: runs the given script up to the given nuber of times or
# until it is successful
function run() {
	local failures=0
	local success=1
	while [[ $failures -lt "$2" && "$success" -eq 1 ]]; do
		"$1"
		success=$?
		failures=$(( $failures + 1 ))
	done
	return $?
}

main
