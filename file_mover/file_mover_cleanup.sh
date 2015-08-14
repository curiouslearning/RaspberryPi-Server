#!/bin/bash
#### BEGIN INIT INFO
# Provides:          file_mover_cleanup.sh 
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: cleans up archived unmoved archive files
# Description: checks that the file mover moved the files it copied to usb stick
### END INIT INFO

# By Jason Krone for Curious Learning
# Date: July 31, 2015

source /home/pi/RaspberryPi-Server/config.sh


function main() {
	echo "from cleanuppp: $( date )" >> /home/pi/RaspberryPi-Server/file_mover/file_mover_log.txt
	
	# see if removal of backedup files was incomplete
	if [[ $( num_files_in_dir "$backup_dir" ) -gt 0 &&
	      $( num_files_in_dir "$archive_dir" ) -gt 0 ]]; then
		echo "there are files in both dirs
		backup_files=( "$backup_dir"* )
		archive_files=( "$archive_dir"* )
		duplicates=$( intersection archive_files[@] backup_files[@] file_eq )
		echo "duplicates: ${duplicates[@]}"
		# remove any duplicates
		for file in ${duplicates[@]}; do
			sudo rm "$file"
		done
	fi
}


# purp: ouputs the number of files in the given directory
# args: path to the directory
function num_files_in_dir() {
	local num_files=$( ls -c "$1" | wc -l )
	echo "$num_files"
}


# purp: outputs true if the given file names excluding prefixes
# are equal and false otherwise
# args: two file paths
function file_eq() {
	# pull prefixes off file names
	local file1=${1##*/}
	local file2=${2##*/}

	if [[ "$file1" == "$file2" ]]; then
		echo "true"	
	else
		echo "false"
	fi		
}


# purp: outputs the intersection of the two lists using elements from $1, using the 
# given function to determine equality
# args: $1 - list one, $2 - list two, $3 - equality function
function intersection() {
	local arr1=("${!1}")
	local arr2=("${!2}")
	local intersect=() # empty list

	for i in ${arr1[@]}; do
		for j in ${arr2[@]}; do
			if [[ $( $3 $i $j ) == "true" ]]; then
				# append item from arr1
				intersect+=($i)
			fi
		done
	done	
	echo ${intersect[@]}
}


main
