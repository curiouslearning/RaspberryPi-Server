#!/bin/bash
# archiver_tests.sh
# By Jason Krone for Curious Learning
# Date: August 18, 2015
# tests archiver
#

dummy_file="/home/pi/RaspberryPi-Server/archiver/dummy_file"
source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/counter.sh


function main() {
	test_norm

	# partial tar in the temp folder with loop of how many files in the temp

	# filure in the movement process... we lose the archive so it's there 
	# the next time , run again and check that it is there
	
	# fiailure in the deletion process, there are files in archive and data base
	# check that they are deleted by cleanup 
}





# purps: creates the given number of .db files and returns 0 if 
# they are properly archived and 1 otherwise
function() test_norm {
	local success=0

	# create .db files
	local dbs=$( create_dummy_files $1 ".db" "$data_dir" )
	
	# run archiver
	/home/pi/RaspberryPi-Server/archiver/archiver.sh

	# check that archiver was successful
	arch_success dbs[@]
	success=$?

	return "$success"
}


# purp: returns 0 if the given files were successfully archived
# and 1 otherwise
# args: array of files to check for in archive
function arch_success() {
	local success="true"
	local files=("${!1}")

	if [[ $( num_files_in_dir "$archiver_temp" ) -ne 0 ]]; then
=		success="false"
	fi

	# get most recent archive 
	local newest_tar=$( ls -t "$archive_dir" | head -1 )	

	# get array of files in most recent tar
	local tar_files=$( tar -tf "$archive_dir"$newest_tar )

	if [[ $( array_eq tar_files[@] files[@] string_equal ) == "false" ]]; then
		success="false"	
	fi

	# get array of files in data dir
	local data_files=( "$data_dir"* )

	# get intersection 
	local duplicates=$( intersection data_files[@] files[@] file_eq )

	# check that there is no intersection
	if [[ "${#duplicates[@]}" -ne 0 ]]; then
		success="false"
	fi
}


# TODO: test this 
# purp: outputs true if the two given arrays are equal and false otherwise
# args: $1 - array1, $2 - array2
	$3 - equal function (outputs false if neq true if eq)
function array_eq() {
	local arr1=("${!1}")
	local arr2=("${!2}")
	local eq="true"

	if [[ "${#arr1[@]}" -eq "${#arr2[@]" ]]; then
		# not sure if this works
		for i in "${!arr1[@]}"; do
			if $( "$3" "${arr1[$i]}" "${files[$i]}" ) == "false"; then
				eq="false"
			fi
		done
	else
		eq="false"
	fi
	
	echo "$eq"
}



# purp: creates the given number of dummy files
# with the given extension in the given folder
# args: $1 - the number of dummy files to create, $2 - file extension
# 	$3 - dummy folder
# rets: outputs an array of paths of the files created
function create_dummy_files() {
	local files_created=()
	for (( i=0; i<$1; i++ )); do
		cp $dummy_file $3$i$2
		files_created+=($i$2)
		echo $i >> $3$i$2
		echo "created file: $i$2"
	done
	echo ${files_created[@]}
}



# pass just name of array to this
# purp: archives the given files and stores them in the given directory
# args: $1 - array of paths to files to archive, 
	$2 - directory to store archive in
# rets: outputs name of archive created
function arch_files() {
	local files=("${!1}")
	local name=$(date +%s)
	tar -czf $2$name.tar.gz ${files[@]} 
	echo "$name"
}

create_dummy_files 5 ".db" $data_dir
