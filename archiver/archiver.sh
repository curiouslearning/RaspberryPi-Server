#!/bin/bash
# archiver.sh
# By Jason Krone for Curious Learning
# Date: June 8, 2015
# archives tablet data
#

source ../config.sh
source ../logger.sh
extension=".db"


function main() {
	echo "running archiver $(date)" >> archiver_log.txt

	# is there >= one file in the directory with the extension
	if [[ $(cd "$data_dir" && ls -c *$extension | wc -l) -gt 0 ]]; then
		archive_dir $data_dir $extension $archive_dir
		exit "$?"
	# there are no files to archive
	else
		exit 0
	fi
}

# purp: archives files with given extension in the given directory and stores
# that archive in the given archive directory
# args: $1 - directory of files to archive, $2 - extension of files to archive(.db), 
#       $3 - path to archive folder
# rets: 0 if successful; otherwise returns non-zero value 
function archive_dir() {
	local success=0

	# get list of files to tar
	local archive_files=($1*$2)
	success=$?
	log_status $success "getting list of files to archive" "archiver_log.txt"

	# use seconds since epoch as archive name
	if [[ "$success" -eq 0 ]]; then
		local arc_name=$(date +%s)
		success=$?
		log_status $success "getting seconds since epoch" "archiver_log.txt"
	fi

	# create archive in temp folder
	if [[ "$success" -eq 0 ]]; then
		(cd $1 && sudo tar -czf $archiver_temp$arc_name.tar.gz ${archive_files[@]##*/})
		success=$?
		log_status $success "archiving files" "archiver_log.txt"
	fi

	# move archived files out of temp
	if [[ "$success" -eq 0 ]]; then
		sudo mv $archiver_temp$arc_name.tar.gz $3$arc_name.tar.gz
		success=$?
		log_status $success "moving archive from temp" "archiver_log.txt"
	fi

	# remove archived files
	if [[ "$success" -eq 0 ]]; then
		# remove listed files and write names
		sudo rm ${archive_files[@]} # check that this works
		success=$?
		log_status $success "removing archived files" "archiver_log.txt"
	fi

	return "$success"
}


main
