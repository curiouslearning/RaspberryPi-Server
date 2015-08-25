#!/bin/bash
# test_space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Tests the space manger
#

source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/array_intersect_utils.sh


# warning for this test to work properly the directories used
# must be empty
function main() {
	test_space_manager 1 1 1 1

	# set the limit to that and then create a number of files
	# create files mix of backups , archives, data
	# for ((b=0;b < $1; b++ )); do
	#	for (( a=0; a<$1; a++ )); do
	#		for (( d=0; d<$1; d++ )); do
	#			#will need to run test in here
	#

}


# purp: test the normal functionality of the space manger 
# creating the given number of input filesa;sdjkfas
# args: $1 - dbs, $2 - archives, $3 - backups, $4 - num files to delete
# $4 must be <= $1 + $2 + $3
function test_space_manager() {
	echo "in test, creating $1 db files, $2 archives, and $3 backups"
	# get space	
	local space=$( python3 space_kb.py )
	echo "space: $space"
	echo "files to delete: $4"
		
	# the order of the following lines matters
	local files=()
	files+=($( create_dummy_files "$3" ".tar.gz" "$backup_dir" ))
	files+=($( create_dummy_files "$2" ".tar.gz" "$archive_dir" ))
	files+=($( create_dummy_files "$1" ".db" "$data_dir" ))
	
	echo "files created: ${files[@]}"

	space_needed="$space"
	local files_to_delete=("${files[@]:0:$4}")
	local files_to_keep=("${files[@]:$4}")
	
	# we will have only have enough extra space for the files to keep 
	for f in "${files_to_keep[@]}"; do
		# add sizeof(f) in kb
		echo "adding size of "$f" to space needed"
		space_needed=$(( $space_needed+$( du "$f" | cut -f1 ) ))
		echo "new space needed: $space_needed"
	done


	#- create a testing flag that will take this as input from command line
	# run the space manager with space needed
	# ./space_manager.sh "$space_needed"
        # TODO: this won't work unless you change the process from bool to num in loop
		
	check_success files_to_keep[@] files_to_delete[@]

	# cleanup i.e. remove files kept
	sudo rm "${files_to_keep[@]}"
	sudo rm "${files_to_delete[@]}" # probably don't need this 
}


function check_success() {
	local success="true"
	local kept_files=("${!1}")
	echo "kept files: $kept_files"
	local deleted_files=( some/file/a some/file/b some/file/c ) #("${!2}")

	# check that none of the kept files were deleted
	for f in "${kept_files[@]}"; do
		# if file does not exist then there was a problem
		if [[ ! -e "$f" ]]; then
			echo "$f which shouldn't have been deleted isn't there"
			success="false"
			break
		fi
	done

	# check that all the files that should have been deleted were
	# get array of files in the order they were deleted by sm
	deletion_log=($( open_file "deleted_files.txt" )) # TODO create tag
	echo "deletion log: ${deletion_log[@]}"

	local len="${#deletion_log[@]}"
	echo "deletion log length: $len"

	for ((i=0; i<"$len"; i++ )); do
		if [[ "${deleted_files[i]}" != "${deletion_log[i]}" ]]; then
			success="false"
			break
		else
			echo "${deleted_files[i]} == ${deletion_log[i]}"
		fi
	done 

	echo "$success"
}


# purp: outputs an array containing the lines in the given file
# args: $1 - file path
function open_file() {
	local i=0
	local array=()

	while read line; do # Read a line
		array[i]=$line # Put it into the array
		i=$(($i + 1))
	done < $1

	echo "${array[@]}"
} 


main
