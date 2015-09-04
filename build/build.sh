#!/bin/bash
# by Jason Krone for Curious Learning
# date: July 23, 2015
# builds weserver system
#

# import logger
source ../logger.sh
build_log="build_log.txt"

function main() {
	../webserver/setup_webserver.sh
	log_status $? "setting up webserver" "$build_log"

	../archiver/setup_archiver.sh
	log_status $? "setting up archiver" "$build_log"

	../file_mover/setup_file_mover.sh
	log_status $? "setting up file_mover" "$build_log"

	# setup cronjobs TODO: modify paths for cron jobs
	crontab ../pi_server_crontab
	log_status $? "setting up crontab" "$build_log"
}

main
